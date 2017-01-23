function Get-PhoneNumber {
    Param(
    # The phone number, in unprocessed form, in any form that may be
    # diablable in the country the phone number originated in.
    [Parameter(Mandatory=$True)]
    [string]$UnprocessedPhoneNumber,

    # The country in which the phone number originated. It may be in
    # a national form (for example: 08-123456), in a country-specific
    # international form (for example 001-800-555-1212) or in an
    # universal international form (for example +1 800 555 1212).
    # For now, only Sweden is a valid source country. If None is specified,
    # only the universal international format will be considered.
    [Parameter(Mandatory=$True)]
    [ValidateSet('None', 'Sweden')]
    $SourceCountry,
    
    [Parameter(Mandatory=$True)]
    [ValidateSet('NormalizedInternational', 'PrettySwedishNational', 'PrettyInternational')]
    $TargetFormat
    )
    
    # Plocka bort allt som inte är 0-9 eller +.
    $p = $UnprocessedPhoneNumber -replace '[^0-9+]', ''

    switch ($SourceCountry) {
        Sweden {
            # Om telefonnumret börjar med 00, byt till +.
            $p = $p -replace '^00', '+'
            
            # Om telefonnumret börjar med 0 (men inte 00), byt till +46
            $p = $p -replace '^0', '+46'
            
            # Om telefonnumret är t.ex. +4608123456, plocka bort 0
            $p = $p -replace '^\+460+', '+46'
        }
    }
    
    # Nu ska telefonnumret bestå av ett + samt siffror i följd. Kolla.
    if ($p -notmatch '^\+\d+$') {
        # Gör det inte det, är det något vi inte kan hantera.
        throw "Unable to normalize PhoneNumber $UnprocessedPhoneNumber"
    }

    if ($TargetFormat -eq 'NormalizedInternational') {
        return $p;
    }

    if ($p -match "^\+(1|46)(\d+)$") {
        $CountryCode = $matches[1]
        $NationalPart = $matches[2]
    } else {
        throw "Unhandled country code in phone number $PhoneNumber"
    }
    
    if ($TargetFormat -eq 'PrettySwedishNational' -and $CountryCode -ne '46') {
        throw "$p is not a swedish number"
    }
    
    switch ($CountryCode) {
        # NANP
        "1" {
            if ($NationalPart -match "^(\d{3})(\d{3})(\d{4})$") {
                $PrettyNationalPart = "($($matches[1])) $($matches[2])-$($matches[3])"
            } else {
                throw "Could not pretty print NANP PhoneNumber $PhoneNumber - unexpected number of digits"
            }
        }
        # Sweden
        "46" {
            $SwedenAreaCodeRegex = (Import-CSV ((Split-Path -parent $SCRIPT:MyInvocation.MyCommand.Path) + "\Data\SwedenAreaCodes.txt") -Delimiter "`t" | % { $_.Riktnummer -replace '^0', ''}) -join '|'
            if ($NationalPart -match "^($SwedenAreaCodeRegex)(\d{2,3})(\d{2,3})(\d{2,3})$") {
                # Hanterar 6-9-siffriga abbonentnummer.
                $PrettyNationalPart = "{1}-{2} {3} {4}" -f (0..4 | % {$matches[$_]}) 
            } elseif ($p -match "^\+46($SwedenAreaCodeRegex)(\d{3})(\d{2})$") {
                # Hanterar 5-siffriga abbonentnummer.
                $PrettyNationalPart = "{1}-{2} {3}" -f (0..3 | % {$matches[$_]}) 
            } else {
                throw "Could not pretty print swedish PhoneNumber $PhoneNumber - unexpected number of digits"
            }
        }
    }
    
    switch ($TargetFormat) {
        PrettySwedishNational {
            return "0$PrettyNationalPart"
        }
        PrettyInternational {
            return "+$CountryCode $PrettyNationalPart"
        }
    }
}
Export-ModuleMember -Function Get-PhoneNumber