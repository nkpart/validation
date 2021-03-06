-- Example that shows how to validate a single value
-- with multiple validation functions/smart constructors.

-- Thanks to @purefn for the help on this!

import Control.Applicative
import Control.Lens
import Data.List (isInfixOf)
import Data.Validation

-- ***** Types *****
newtype AtString = AtString String deriving (Show)
newtype PeriodString = PeriodString String deriving (Show)
newtype NonEmptyString = NonEmptyString String deriving (Show)

newtype Email = Email String deriving (Show)

data VError = MustNotBeEmpty
            | MustContainAt
            | MustContainPeriod
            deriving (Show)

-- ***** Base smart constructors *****
-- String must contain an '@' character
atString :: String -> AccValidation [VError] AtString
atString x = if "@" `isInfixOf` x
             then _Success # AtString x
             else _Failure # [MustContainAt]

-- String must contain an '.' character
periodString :: String -> AccValidation [VError] PeriodString
periodString x = if "." `isInfixOf` x
                 then _Success # PeriodString x
                 else _Failure # [MustContainPeriod]

-- String must not be empty
nonEmptyString :: String -> AccValidation [VError] NonEmptyString
nonEmptyString x = if x /= []
                   then _Success # NonEmptyString x
                   else _Failure # [MustNotBeEmpty]

-- ***** Combining smart constructors *****
email :: String -> AccValidation [VError] Email
email x = pure (Email x)   <*
          nonEmptyString x <*
          atString       x <*
          periodString   x

-- ***** Example usage *****
success = email "bob@gmail.com"
-- AccSuccess (Email "bob@gmail.com")

failureAt = email "bobgmail.com"
-- AccFailure [MustContainAt]

failurePeriod = email "bob@gmailcom"
-- AccFailure [MustContainPeriod]

failureAll = email ""
-- AccFailure [MustNotBeEmpty,MustContainAt,MustContainPeriod]

main :: IO ()
main = do
  putStrLn $ "email \"bob@gmail.com\": " ++ show success
  putStrLn $ "email \"bobgmail.com\":  " ++ show failureAt
  putStrLn $ "email \"bob@gmailcom\":  " ++ show failurePeriod
  putStrLn $ "email \"\":              " ++ show failureAll
