Hakyll script for building http://alex.hirzel.us

Alexander Hirzel, August, 2011

Examples: https://github.com/jaspervdj/hakyll-examples

> {-# LANGUAGE OverloadedStrings #-}
> import Hakyll

blah

> main = hakyll $ do

Ensure CSS files receive no special treatment.

>   match "*.css" $ do
>     route idRoute
>     compile compressCssCompiler
>     compile copyFileCompiler
