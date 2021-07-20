{- |
Module      : Kore.Simplify.Top
Description : Tools for Top pattern simplification.
Copyright   : (c) Runtime Verification, 2018-2021
License     : BSD-3-Clause
Maintainer  : virgil.serbanuta@runtimeverification.com
Stability   : experimental
Portability : portable
-}
module Kore.Simplify.Top (
    simplify,
) where

import Kore.Internal.OrPattern (
    OrPattern,
 )
import qualified Kore.Internal.OrPattern as OrPattern
import Kore.Rewrite.RewritingVariable (
    RewritingVariableName,
 )
import Kore.Sort
import Kore.Syntax.Top
import Prelude.Kore ()

-- | simplifies a Top pattern, which means returning an always-true or.

-- TODO (virgil): Preserve pattern sorts under simplification.
simplify ::
    Sort ->
    Top Sort child ->
    OrPattern RewritingVariableName
simplify sort _ = OrPattern.top sort