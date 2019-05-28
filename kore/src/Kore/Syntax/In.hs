{-|
Copyright   : (c) Runtime Verification, 2019
License     : NCSA

-}

{-# LANGUAGE TemplateHaskell #-}

module Kore.Syntax.In
    ( In (..)
    ) where

import           Control.DeepSeq
                 ( NFData (..) )
import qualified Data.Deriving as Deriving
import           Data.Hashable
import qualified Data.Text.Prettyprint.Doc as Pretty
import qualified Generics.SOP as SOP
import qualified GHC.Generics as GHC

import Kore.Debug
import Kore.Sort
import Kore.Unparser

{-|'In' corresponds to the @\in@ branches of the @object-pattern@ and
@meta-pattern@ syntactic categories from the Semantics of K,
Section 9.1.4 (Patterns).

'inOperandSort' is the sort of the operands.

'inResultSort' is the sort of the result.

-}
data In sort child = In
    { inOperandSort     :: !sort
    , inResultSort      :: !sort
    , inContainedChild  :: child
    , inContainingChild :: child
    }
    deriving (Eq, Functor, Foldable, GHC.Generic, Ord, Show, Traversable)

Deriving.deriveEq1 ''In
Deriving.deriveOrd1 ''In
Deriving.deriveShow1 ''In

instance (Hashable sort, Hashable child) => Hashable (In sort child)

instance (NFData sort, NFData child) => NFData (In sort child)

instance SOP.Generic (In sort child)

instance SOP.HasDatatypeInfo (In sort child)

instance (Debug sort, Debug child) => Debug (In sort child)

instance Unparse child => Unparse (In Sort child) where
    unparse
        In
            { inOperandSort
            , inResultSort
            , inContainedChild
            , inContainingChild
            }
      =
        "\\in"
        <> parameters [inOperandSort, inResultSort]
        <> arguments [inContainedChild, inContainingChild]

    unparse2
        In
            { inContainedChild
            , inContainingChild
            }
      = Pretty.parens (Pretty.fillSep
            [ "\\in"
            , unparse2 inContainedChild
            , unparse2 inContainingChild
            ])