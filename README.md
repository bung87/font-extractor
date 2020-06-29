# font-extractor [![Build Status](https://travis-ci.org/bung/font-extractor.svg?branch=master)](https://travis-ci.org/bung/font-extractor) [![Npm Version](https://badgen.net/npm/v/font-extractor)](https://www.npmjs.com/package/font-extractor) ![npm: total downloads](https://badgen.net/npm/dt/font-extractor) ![Dep](https://badgen.net/david/dep/bung87/font-extractor) ![license](https://badgen.net/npm/license/font-extractor)  

## Installation

`yarn add font-extractor -D`  

or  

`npm i --save-dev font-extractor`  

## Usage  

extract subset of font from text content or website for CJK website  

supported format `ttf, eot, woff, svg`  

`puppeteer` as `peerDependencies` if you'd like use headless mode 
extract from website  

install `puppeteer` dependencies on CentOS  
`yum install pango.x86_64 libXcomposite.x86_64 libXcursor.x86_64 libXdamage.x86_64 libXext.x86_64 libXi.x86_64 libXtst.x86_64 cups-libs.x86_64 libXScrnSaver.x86_64 libXrandr.x86_64 GConf2.x86_64 alsa-lib.x86_64 atk.x86_64 gtk3.x86_64 ipa-gothic-fonts xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-utils xorg-x11-fonts-cyrillic xorg-x11-fonts-Type1 xorg-x11-fonts-misc -y`  

[recommended] Enable user namespace cloning

`sudo sysctl -w kernel.unprivileged_userns_clone=1`

### extract statically  

extract from local files literal string.  

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

extract text styled with specific font face name in web page.   

```
font-extractor headless -e http://139.198.17.136:8080/book/46 -o ./a.ttf --fname zkkl --ss '.books-wrapper' -f

Options:
  --version            Show version number                             [boolean]
  --help               Show help                                       [boolean]
  -c                   config file
  --entry, -e          entry url                                        [string]
  --output, -o         output file path                                 [string]
  --fontname, --fname  font face name
  --scroller, --ss       scroll element selector(querySelector)           [string]
  --scrollwait --sw    time wait after scroll(ms) default:300
  --font, -f           font file path                                   [string]
  --preserved, -p      preserved words                     [array] [default: []]
```
## Acknowledgement  

[JailBreakC/font-collector](https://github.com/JailBreakC/font-collector)  

[purplebamboo/font-carrier](https://github.com/purplebamboo/font-carrier)  
