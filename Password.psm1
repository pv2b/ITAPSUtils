<#
.SYNOPSIS
Generates a random password

.DESCRIPTION
Generates a random password with at least 1 uppercase letter, 1 lowercase
letter, and 1 digit in the password, with a given length.
#>


# Generates an n-character password with at least 1 capital, 1 lowercase and 1 digit
function New-Password {
    Param(
    $Length = 10
    )


#TODO parameter validation length>=3
#generalize?

    # Generate a list of the character codes of all uppercase letters
    $upper = [char]'A' .. [char]'Z' | % { [char]$_ }
    
    # Generate a list of the character codes of all lowercase letters
    $lower = [char]'a' .. [char]'z' | % { [char]$_ }
    
    # Generate a list of the character codes of all digits
    $digits = [char]'0' .. [char]'9' | % { [char]$_ }
    
    # Generate a list of all possible password characters (uppercase letters, lowercase letters, and digits)
    $all = $upper + $lower + $digits
    
    # Create an empty array to hold the characters to be used in the password
    $passwordchars = @()
    
    # Password needs to contain at least one uppercase letter
    $passwordchars += @(Get-Random $upper)

    # Password needs to contain at least one lowercase letter
    $passwordchars += @(Get-Random $lower)

    # Password needs to contain at least one digit
    $passwordchars += @(Get-Random $digits)
    
    # Fill up $passwordchars with any type of random character, up to the length of the password
    while ($passwordchars.Count -lt $length) {
        $passwordchars += @(Get-Random $all)
    }
    
    # $passwordchars now contains, in the following order:
    # - 1 uppercase letter
    # - 1 lowercase letter
    # - 1 digit
    # - $length-3 other characters
    # However, as is, this is not a good password, because even though it
    # fulfills the password complexity requirements, it is predictable that
    # the first three characters are in a certain character class.
    # For this reason, these generated characters are shuffled into a random
    # order which eliminates this weakness.
    return ($passwordchars | Get-Random -Count $length) -join ''
}