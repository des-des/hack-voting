module Firebase.Core
       ( App
       , initializeApp
       , Config
       , FIREBASE
       )
       where

import Control.Monad.Eff (Eff, kind Effect)
import Control.Monad.Eff.Exception (EXCEPTION)

foreign import data FIREBASE :: Effect

type Config =
  { apiKey :: String
  , authDomain :: String
  , databaseURL :: String
  , storageBucket :: String
  }

foreign import data App :: Type

foreign import initializeApp ::
  forall eff.
  Config -> Eff (exception :: EXCEPTION, firebase :: FIREBASE | eff) App
