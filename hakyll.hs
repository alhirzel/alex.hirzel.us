-- Hakyll script for building http://alex.hirzel.us
-- Alexander Hirzel <alex@hirzel.us>
-- August, 2011

-- Resources:
--   https://github.com/jaspervdj/hakyll-examples

-- Areas of future work:
--   https://groups.google.com/d/topic/hakyll/p-zk3MFQ_ts/discussion

{-# LANGUAGE OverloadedStrings #-}
import Hakyll
import Control.Arrow
import System.FilePath
import Data.Monoid
import Text.Pandoc



config :: HakyllConfiguration
config = defaultHakyllConfiguration {
  deployCommand = "make deploy",
  destinationDirectory = "htdocs"
}


-- TODO: add something here to populate siteKeys
bestCompilerEver =
  pageCompilerWith defaultParserState defaultWriterOptions >>>
  applyTemplateCompiler "default.mt" >>>
  relativizeUrlsCompiler


main = hakyllWith config $ do

  match "*.css" $ do
    route idRoute
    compile copyFileCompiler

  match "*.mt" $ do
    compile templateCompiler

  match "pages/*.page" $ do
    route $ upDirRoute `composeRoutes` setExtension ".html"
    compile bestCompilerEver

  match "pages/*.jpg" $ do
    route upDirRoute
    compile copyFileCompiler

  -- create empty favicon.ico and robots.txt (for performance on NearlyFreeSpeech)
  match "favicon.ico" $ route idRoute
  create "favicon.ico" $ (constA mempty :: Compiler () String)
  match "favicon.ico" $ route idRoute
  create "favicon.ico" $ (constA mempty :: Compiler () String)



-- | Route which uses @upDir'@ to chop off the top-level directory during routing.
--
-- >>> route upDirRoute
--
-- >>> route $ upDirRoute `composeRoutes` upDirRoute
upDirRoute :: Routes
upDirRoute = customRoute $ upDir . toFilePath

-- | Chops off the top-level directory from a @FilePath@.
--
-- >>> upDir' "/foo/bar/baz"
-- "/bar/baz"
--
-- >>> upDir' "foo/bar/baz"
-- "bar/baz"
upDir :: FilePath -> FilePath
upDir = joinPath . dropTopDir . splitDirectories
  where
    dropTopDir ("/":x2:xs) = "/" : tail xs
    dropTopDir (x1 :x2:xs) = x2:xs
