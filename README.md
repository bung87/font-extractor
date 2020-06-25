# font-extractor [![Build Status](https://travis-ci.org/bung/font-extractor.svg?branch=master)](https://travis-ci.org/bung/font-extractor) [![Npm Version](https://badgen.net/npm/v/font-extractor)](https://www.npmjs.com/package/font-extractor) ![npm: total downloads](https://badgen.net/npm/dt/font-extractor) ![Dep](https://badgen.net/david/dep/bung/font-extractor) ![license](https://badgen.net/npm/license/font-extractor)  

## Installation

`yarn add font-extractor -D`  

or  

`npm i --save-dev font-extractor`  

## Usage  

extractor subset of font from text content for CJK website   
supported format `ttf, eot, woff, svg`  

### extract statically  

```
font-extractor static -f test/lib/handfont.ttf -s test/index.html -o test/fonts/handfont

Options:
  --version        Show version number                                 [boolean]
  --source, -s     source glob pattern                                [required]
  --ignore, -i     ignore glob pattern
  --font, -f       font file path                                     [required]
  --preserved, -p  preserved words                         [array] [default: []]
  --encoding, -e   file encoding                     [string] [default: "utf-8"]
  --output, -o     output file path                                   [required]
  -c               config file
  --help           Show help                                           [boolean]

```

### Example config file  

```
{
    "source": {
        "path": ["src/**/*.vue"]
    },

    "font": "src/assets/fonts/站酷快乐体2016修订版.ttf",

    "output": "dist/fonts/站酷快乐体2016修订版.0aceab97.ttf"
}
```
### extract from website  
```
font-extractor headless -e http://139.198.17.136:8080/book/46 -o ./a.ttf --fname zkkl --ss '.books-wrapper' -f

Options:
  --version            Show version number                             [boolean]
  --help               Show help                                       [boolean]
  -c                   config file
  --entry, -e          entry url                                        [string]
  --output, -o         output file path                                 [string]
  --fontname, --fname  font face name
  --scroll, --ss       scroll element selector(querySelector)           [string]
  --font, -f           font file path                                   [string]
  --preserved, -p      preserved words                     [array] [default: []]
```
## Acknowledgement  

[JailBreakC/font-collector)](https://github.com/JailBreakC/font-collector)  

[purplebamboo/font-carrier](https://github.com/purplebamboo/font-carrier)  
