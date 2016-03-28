# gulp-module-packer

It helps you to inject js and css into html and to concatenate them in the correct order.

## Usage

First you need to create `modpack.json` next to your `gulpfile.js`

You can list multiples HTML that will be injected. For each HTML you should define a list of macros for both JS and CSS.

Then you define the content of each macro.

Exemple:

```json
{
    "inject": {
        "index.html": {
            "js": [
                "base",
                "app"
            ],
            "css": [
                "app"
            ]
        },
        "index-ionic.html": {
            "js": [
                "base",
                "ionic"
            ],
            "css": [
                "ionic"
            ]
        }
    },
    "js": {
        "app": [
            "app.js",
            "routes.js",
        ],
        "base": [
            "angular.js",
            "angular-animate.js",
            "angular-ui-router.js"
        ],
        "ionic": [
            "ionic-bundle.js"
        ]
    },
    "css": {
        "app": [
            "app.css"
        ],
        "ionic": [
            "ionic.css"
        ]
    }
}
```

Your HTML should include 2 placeholders:

```html
<!DOCTYPE html>
<html lang="pt-br" ng-app="azApp">
  <head>
    <title>azMove</title>
    <link rel="shortcut icon" href="favicon.ico">
    <!-- gmp:inject:css -->
    <!-- gmp:end -->
  </head>
  <body>
    <div id="main-div" ui-view></div>
    <script src="//maps.google.com/maps/api/js"></script>
    <!-- gmp:inject:js -->
    <!-- gmp:end -->
  </body>
</html>

```

Finally a nice example:

```javascript
```

`gulp-module-packer.concat(options)`

options | defaut | description
-------|--------|-------------
`configFile` | `'modpack.json'` | Name of configuration file
`target`| | `'css'` or `'js'`
`min` | `false` | if true then include '.min' to concatenated filename
`hash` | `''` | added between filename and [.min].(js/css)

Please note that if you set `options.min` true in here all it does is to include the `.min` to its name. You still have to pipe a minifier after this. (In other words: now you don't have to pipe a rename just to include `.min` to your filename).

`gulp-module-packer.inject(options)`

options | defaut | description
--------|--------|-----------
`configFile` | `modpack.json` | Name of configuration file
`min` | `false` | if true then include '.min' to injected file
`dev` | `true` | if true inject developping file instead of concatened files
`keepComment` | `true` | keep the placeholder comment wraping the injection
`hash` | `''` | added between filename and [.min].(js/css)
`jsStart` | |
`jsEnd` | |
`cssStart` | |
`cssEnd` | |


Please note that this function does not handle files, all it does is to inject elements inside your HTML code. So, if you set `options.min` true for instance all it does it to inject `<script src="app.min.js"></script>` (including the min to its name). Is up to you to generate that minified file elsewhere.
