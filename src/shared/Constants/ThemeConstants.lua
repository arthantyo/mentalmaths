local ThemeConstants = {}

ThemeConstants.Themes = {
    SUBTRACTION_AND_ADDITION = {
        Id = "SUBTRACTION_AND_ADDITION",
        DisplayName = "Add x Subtract",
        Description = "Solve addition and subtraction!"
    },
    MULTIPLICATION_AND_DIVISION = {
        Id = "MULTIPLICATION_AND_DIVISION",
        DisplayName = "Multiply x Divide",
        Description = "Tackle multiplication and division!"
    },
    MIXED = {
        Id = "MIXED",
        DisplayName = "Mixed Manics",
        Description = "A mix of all operations!"
    },
    FRACTION = {
        Id = "FRACTION",
        DisplayName = "Fraction Frenzy",
        Description = "Simplify fractions!"
    }
}

ThemeConstants.AllThemes = {
    ThemeConstants.Themes.SUBTRACTION_AND_ADDITION,
    ThemeConstants.Themes.MULTIPLICATION_AND_DIVISION,
    ThemeConstants.Themes.MIXED,
    ThemeConstants.Themes.FRACTION,
}

return ThemeConstants