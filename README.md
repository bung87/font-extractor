# font-extract [![Build Status](https://travis-ci.org/bung/font-extract.svg?branch=master)](https://travis-ci.org/bung/font-extract) [![Npm Version](https://badgen.net/npm/v/font-extract)](https://www.npmjs.com/package/font-extract) ![npm: total downloads](https://badgen.net/npm/dt/font-extract) ![Dep](https://badgen.net/david/dep/bung/font-extract) ![license](https://badgen.net/npm/license/font-extract)  

## Installation

`yarn add font-extract`  

or  

`npm i --save font-extract`  

## Usage  

extract subset of font from text content for CJK website   
supported format `ttf, eot, woff, svg`

```
font-extract -f test/lib/handfont.ttf -s test/index.html -o test/fonts/handfont

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

## Acknowledgement  

[JailBreakC/font-collector)](https://github.com/JailBreakC/font-collector)  

[purplebamboo/font-carrier](https://github.com/purplebamboo/font-carrier)  
