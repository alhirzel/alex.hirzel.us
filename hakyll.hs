-- Hakyll script for building http://alex.hirzel.us
-- Alexander Hirzel, August, 2011
-- Examples: https://github.com/jaspervdj/hakyll-examples

{-# LANGUAGE OverloadedStrings #-}
import Hakyll
import Control.Arrow

config :: HakyllConfiguration
config = defaultHakyllConfiguration {
  destinationDirectory = "htdocs"
}

main = hakyllWith config $ do

-- Ensure CSS files receive no special treatment.
  match "*.css" $ do
    route idRoute
    compile copyFileCompiler
