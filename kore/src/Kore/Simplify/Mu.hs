{- |
Copyright   : (c) Runtime Verification, 2018-2021
License     : BSD-3-Clause
-}
module Kore.Simplify.Mu (
    simplify,
    makeEvaluate,
) where

import Kore.Internal.OrPattern (
    OrPattern,
 )
import qualified Kore.Internal.OrPattern as OrPattern
import Kore.Internal.Pattern (
    Pattern,
 )
import qualified Kore.Internal.Pattern as Pattern (
    fromTermLike,
    toTermLike,
 )
import Kore.Internal.TermLike (
    Mu (Mu),
    SetVariable,
    mkMu,
 )
import qualified Kore.Internal.TermLike as TermLike.DoNotUse
import Kore.Rewrite.RewritingVariable (
    RewritingVariableName,
 )
import Prelude.Kore

{- |'simplify' simplifies a 'Mu' pattern with an 'OrPattern'
child.
-}
simplify ::
    Mu RewritingVariableName (OrPattern RewritingVariableName) ->
    OrPattern RewritingVariableName
simplify Mu{muVariable, muChild} =
    OrPattern.map (makeEvaluate muVariable) muChild

{- | evaluates a 'Mu' given its two 'Pattern' children.

See 'simplify' for detailed documentation.
-}
makeEvaluate ::
    SetVariable RewritingVariableName ->
    Pattern RewritingVariableName ->
    Pattern RewritingVariableName
makeEvaluate variable patt =
    Pattern.fromTermLike $
        mkMu variable $
            Pattern.toTermLike patt
