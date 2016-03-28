# gulp-module-packer

It helps you to inject js and css into html and to concatenate them in the correct order.

## Usage

This package will help you with 3 things:

- inject code into your HTML (keeping the order)
- concatenate your files into modules (keeping the order)
- list all available js/css to your project

### Inject

First you need to create `modpack.json` next to your `gulpfile.js`

You can list multiples HTML that will be injected. For each HTML you should define a list of modules for both JS and CSS.

Then you define the content of each module.

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
                "app-css"
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
        "app-css": [
            "bootstrap.css",
            "app.css"
        ],
        "ionic": [
            "ionic.css"
        ]
    }
}
```

Your HTML files should include 2 placeholders:

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="pt-br" ng-app="myApp">
  <head>
    <title>My App</title>
    <link rel="shortcut icon" href="favicon.ico">
    <!-- gmp:inject:css -->
    <!-- gmp:end -->
  </head>
  <body>
    <div id="main-div" ui-view></div>
    <script src="//any/external/stuff.js"></script>
    <!-- gmp:inject:js -->
    <!-- gmp:end -->
  </body>
</html>
```

Finally a simples `gulpfile`:

```javascript
var packer = require('gulp-module-packer');

gulp.task('inject', function(){
    return gulp.src('www/**/*.html')
        .pipe(packer.inject({
            dev  : false,
            min  : true,
            hash : '.12345' //useful if set to your git hash
        }))
        .pipe(gulp.dest('dist'));
});
```

Will render to:

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="pt-br" ng-app="myApp">
  <head>
    <title>My App</title>
    <link rel="shortcut icon" href="favicon.ico">
    <!-- gmp:inject:css -->
    <link rel="stylesheet" href="app-css.12345.min.css">
    <!-- gmp:end -->
  </head>
  <body>
    <div id="main-div" ui-view></div>
    <script src="//any/external/stuff.js"></script>
    <!-- gmp:inject:js -->
    <script src="base.12345.min.js"></script>
    <script src="app.12345.min.js"></script>
    <!-- gmp:end -->
  </body>
</html>
```

If you set `min: false` and `hash: ''` then:

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="pt-br" ng-app="myApp">
  <head>
    <title>My App</title>
    <link rel="shortcut icon" href="favicon.ico">
    <!-- gmp:inject:css -->
    <link rel="stylesheet" href="app-css.css">
    <!-- gmp:end -->
  </head>
  <body>
    <div id="main-div" ui-view></div>
    <script src="//any/external/stuff.js"></script>
    <!-- gmp:inject:js -->
    <script src="base.js"></script>
    <script src="app.js"></script>
    <!-- gmp:end -->
  </body>
</html>
```

And for `dev: true`:

```html
<!-- index.html -->
<!DOCTYPE html>
<html lang="pt-br" ng-app="myApp">
  <head>
    <title>My App</title>
    <link rel="shortcut icon" href="favicon.ico">
    <!-- gmp:inject:css -->
    <link rel="stylesheet" href="bootstrap.css">
    <link rel="stylesheet" href="app.css">
    <!-- gmp:end -->
  </head>
  <body>
    <div id="main-div" ui-view></div>
    <script src="//any/external/stuff.js"></script>
    <!-- gmp:inject:js -->
    <script src="angular.js"></script>
    <script src="angular-animate.js"></script>
    <script src="angular-ui-router.js"></script>
    <script src="app.js"></script>
    <script src="routes.js"></script>
    <!-- gmp:end -->
  </body>
</html>
```

### Concatenate

### List

## API

`gulp-module-packer.concat(options)`

| option         | defaut           | description                                               |
|:---------------|:-----------------|:----------------------------------------------------------|
| `configFile`   | `'modpack.json'` | name of configuration file                                |
| `target`       |                  | `'css'` or `'js'`                                         |
| `keepConsumed` | `false`          | Keep inside stream any file consumed during concatenation |
| `min`          | `false`          | if true then include '.min' to concatenated filename      |
| `hash`         | `''`             | added between filename and [.min].(js/css)                |

Please note that if you set `options.min` true in here all it does is to include the `.min` to its name. You still have to pipe a minifier after this. (In other words: you don't have to pipe a rename just to include `.min` to your filename).

`gulp-module-packer.inject(option)`

| option        | defaut                              | description                                                 |
|:--------------|:------------------------------------|:------------------------------------------------------------|
| `configFile`  | `modpack.json`                      | name of configuration file                                  |
| `min`         | `false`                             | if true then include '.min' to injected file                |
| `dev`         | `true`                              | if true inject developping file instead of concatened files |
| `keepComment` | `true`                              | keep the placeholder comment wraping the injection          |
| `hash`        | `''`                                | added between filename and [.min].(js/css)                  |
| `jsStart`     | `'\n<script src="'`                 |                                                             |
| `jsEnd`       | `'"></script>'`                     |                                                             |
| `cssStart`    | `'\n<link rel="stylesheet" href="'` |                                                             |
| `cssEnd`      | `'">'`                              |                                                             |

Please note that this function does not handle files, all it does is to inject elements inside your HTML code. So, if you set `options.min` true for instance all it does it to inject `<script src="app.min.js"></script>` (including the min to its name). Is up to you to generate that minified file elsewhere.
