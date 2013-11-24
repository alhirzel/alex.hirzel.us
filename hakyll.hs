-- Hakyll script for building http://alex.hirzel.us
-- Alexander Hirzel <alex@hirzel.us>
-- August, 2011

-- Resources:
--   https://github.com/jaspervdj/hakyll-examples
--   http://citationneeded.me/
--   http://jaspervdj.be/hakyll/tutorials/hakyll-3-to-hakyll4-migration-guide.html
--   http://sigkill.dk/programs/sigkill.html

-- Areas of future work:
--   https://groups.google.com/d/topic/hakyll/p-zk3MFQ_ts/discussion

import Hakyll
import System.FilePath
import Data.Monoid
import Control.Applicative ((<$>))
import Text.Pandoc



config = defaultConfiguration {
  deployCommand = "rsync -rv htdocs/ nfsn:/home/public",
  destinationDirectory = "htdocs"
}



main :: IO ()
main = let s --> r = match (fromGlob s) r
        in hakyllWith config $ do

  -- Use empty favicon.ico and robots.txt for performance reasons on NFSN
  -- (http://blog.nearlyfreespeech.net/2009/06/16/quick-wordpress-performance-tip-create-a-favicon/)
  emptyfile "favicon.ico"
  emptyfile "robots.txt"

  -- List out the remaining file types
  "pages/**.page" --> markdown upDirRoute
  "pages/**.jpg"  --> static upDirRoute
  "pages/**.png"  --> static upDirRoute
  "*.css"         --> css
  "*.scss"        --> sassycss
  "*.mt"          --> template



emptyfile :: String -> Rules ()
emptyfile fn = create [fromFilePath fn] $ do route idRoute
                                             compile $ makeItem ""

template   = do compile templateCompiler

static r   = do route   r
                compile copyFileCompiler

css        = do route   idRoute
                compile compressCssCompiler

sassycss   = do route   $ setExtension ".css"
                compile $ getResourceString >>=
                          withItemBody (unixFilter "scss" ["-s"]) >>=
                          return . fmap compressCss

markdown r = do route   $ r `composeRoutes` setExtension ".html"
                compile $ myPandocCompiler
                          >>= loadAndApplyTemplate template defaultContext
                          >>= relativizeUrls
                  where template = fromFilePath "default.mt"



myPandocCompiler :: Compiler (Item String)
myPandocCompiler = cached cacheName $ writePandocWith wopt . (fmap $ readMarkdown ropt) <$> getResourceBody
  where
    cacheName = "Hakyll.Web.Page.pageCompilerWithPandoc"
    ropt = defaultHakyllReaderOptions { readerInitialURLs = [("mtu", "mtu", "mtu")] }
    wopt = defaultHakyllWriterOptions



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
