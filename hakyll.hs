-- Hakyll script for building http://alex.hirzel.us
-- Alexander Hirzel <alex@hirzel.us>
-- August, 2011

-- Resources:
--   https://github.com/jaspervdj/hakyll-examples
--   http://citationneeded.me/

-- Areas of future work:
--   https://groups.google.com/d/topic/hakyll/p-zk3MFQ_ts/discussion

{-# LANGUAGE OverloadedStrings #-}

import Prelude hiding (id)
import Hakyll
import Control.Arrow
import Control.Applicative
import Control.Monad
import System.FilePath
import Data.Monoid
import Text.Pandoc



config = defaultHakyllConfiguration {
  deployCommand = "rsync -rv htdocs/ nfsn:/home/public",
  destinationDirectory = "htdocs"
}



main = hakyllWith config $ do

    -- Use empty favicon.ico and robots.txt for performance reasons on NFSN
    emptyfile "favicon.ico"
    emptyfile "robots.txt"

    ["*.mt"]         --> [template]
    ["pages/*.page"] --> [markdown]
    ["*.scss"]       --> [scss]
    ["pages/*.jpg"]  --> [static]
    ["pages/*.png"]  --> [static]
    ["*.css"]        --> [css]
    ["favicon.ico"]  --> [static]
    ["robots.txt"]   --> [static]

  where fs --> rs = sequence (fs <**> rs)
        emptyfile fn = create fn $ (constA mempty :: Compiler () String)



template :: Pattern (Identifier Template) -> RulesM ()
template pat = void $ match pat $ do
  compile templateCompiler

static :: Pattern (Page String) -> RulesM ()
static pat = void $ match pat $ do
  route upDirRoute
  compile copyFileCompiler

css :: Pattern (Page String) -> RulesM ()
css pattern = void $ match pattern $ do
               route idRoute
               compile $ getResourceString >>> arr compressCss

scss :: Pattern (Page String) -> RulesM ()
scss pattern = void $ match pattern $ do
                route (setExtension ".css")
                compile $ getResourceString
                  >>> unixFilter "scss" ["-s"]
                  >>> arr compressCss

markdown :: Pattern (Page String) -> RulesM ()
markdown pat = void $ match pat $ do
  route $ upDirRoute `composeRoutes` setExtension ".html"
  compile $ pageCompilerWith pstate wstate
            >>> applyTemplateCompiler template
            >>> relativizeUrlsCompiler
    where template = "default.mt"
          wstate = defaultWriterOptions { writerHtml5 = True }
          pstate = defaultParserState



-- | Route which uses @upDir'@ to chop off the top-level directory during routing.
--
-- >>> route upDirRoute
--
-- >>> route $ upDirRoute `composeRoutes` upDirRoute
upDirRoute :: Routes
upDirRoute = customRoute $ upDir . toFilePath

-- | Chops off the top-level directory from a @FilePath@.
--
-- >>> upDir "/foo/bar/baz"
-- "/bar/baz"
--
-- >>> upDir "foo/bar/baz"
-- "bar/baz"
upDir :: FilePath -> FilePath
upDir = joinPath . dropTopDir . splitDirectories
  where
    dropTopDir ("/":x2:xs) = "/" : tail xs
    dropTopDir (x1 :x2:xs) = x2:xs
    dropTopDir xs          = xs

-- vim:set et sw=2:
