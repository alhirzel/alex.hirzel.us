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

config :: HakyllConfiguration
config = defaultHakyllConfiguration {
  deployCommand = "make deploy",
  destinationDirectory = "htdocs"
}



main = hakyllWith config $ do

  match "*.css" $ do
    route idRoute
    compile copyFileCompiler

  match "*.mt" $ do
    compile templateCompiler

  match "pages/*.page" $ do
    route $ upDirRoute `composeRoutes` setExtension ".html"
    compile $ pageCompiler >>> applyTemplateCompiler "bare.mt"
                           >>> relativizeUrlsCompiler

  match "pages/*.jpg" $ do
    route upDirRoute
    compile copyFileCompiler

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
