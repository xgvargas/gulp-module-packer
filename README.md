# gulp-module-packer

It helps you to inject js and css into html and to concatenate them in the correct order.

## Instalation

```bash
npm install --save-dev gulp-module-packer
```

## Usage

This plugin will help you with 3 things:

- inject code into your HTML (keeping file order)
- concatenate your files into modules (keeping file order)
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

Finally a simple `gulpfile`:

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
    <!-- app-css -->
    <link rel="stylesheet" href="bootstrap.css">
    <link rel="stylesheet" href="app.css">
    <!-- gmp:end -->
  </head>
  <body>
    <div id="main-div" ui-view></div>
    <script src="//any/external/stuff.js"></script>
    <!-- gmp:inject:js -->
    <!-- base -->
    <script src="angular.js"></script>
    <script src="angular-animate.js"></script>
    <script src="angular-ui-router.js"></script>
    <!-- app -->
    <script src="app.js"></script>
    <script src="routes.js"></script>
    <!-- gmp:end -->
  </body>
</html>
```

For any HTML file not listed in `modpack.json`, `gulp-module-packer.inject()` will behave as a pass-through.

### Concatenate

For every module inside `js` and `css` in your `modpack.json` this plugin will create a file with the content of every file listed for this module in the same order they are listed.

Also you can consume files already in the stream to be concatenated too. Example:

```json
{
    "inject": {
        "index.html": {
            "js": [
                "base",
                "myapp"
            ],
            "css": [...]
        }
    },
    "js": {
        "myapp": [
            "app.js",
            "::templates.js"
            "route/routes.js",
        ],
        "base": [...]
    },
    "css": {
        "app-css": [...]
    }
}
```

Here, after concatenation, the module `myapp.js` will include `app.js` file, then the content of a stream named `templates.js` and finally the `route/routes.js` file.

During injection with `dev: true` the file `templates.js` will *NOT* be injected.

If the `gulp-module-packer.concat()` is called with `keepConsumed: true` then the file `templates.js` will be left untouched in the stream and will be saved as real file in next `gulp.dest()`.

Example:

```javascript
var packer = require('gulp-module-packer');

var GIT_HASH = sh.exec('git rev-parse --short HEAD', {silent: true}).output.trim();

gulp.task('release-js', function(){
    return gulp.src('www/templates/*.html')
        .pipe(htmlMinifier({
            removeComments     : true,
            collapseWhitespace : true,
        }))
        .pipe(angularTemplatecache({
            filename   : 'templates.js'
            root       : 'templates',
            module     : 'templates',
            standalone : false
        }))
        .pipe(packer.concat({
            hash: GIT_HASH,
        }))
        .pipe(ngAnnotate())
        .pipe(bytediff.start())
        .pipe(uglify({
            preserveComments : 'license',
            compress : {
                drop_console : true,
            },
        }))
        .on('error', dealWithError)
        .pipe(plugins.bytediff.stop())
        .pipe(gulp.dest('dist/js'));
})
```

This nice example for angular will generate a template cache for all HTML files and then use gulp-module-packer.concat() to pack it with all other .js files.

### List

To keep the `modpack.json` file updated is a manual work. You should include all .js and .css files in their correct position, this is up to you to do. But, this module can help you by listing all available .js and .css in your project, so all you have to do is move them to the correct position and simply ignore the available files that should be ignored.

A simple task like this will do the job:

```javascript
var packer = require('gulp-module-packer');

gulp.task('available', function(){
    return gulp.src(['www/**/*.js', 'www/**/*.css'], {read: false}).pipe(packer.list());
})
```

and will alter your `modpack.json` to include a `available` field with all unused files available. Example:

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
        ]
    },
    "css": {
        "app-css": [
            "bootstrap.css",
            "app.css"
        ]
    },
    "available": [
        "js\\authentication.c.js",
        "js\\config.js",
        "lib\\angular-sanitize\\angular-sanitize.js",
        "lib\\velocity\\velocity.js",
        "lib\\angular-formly\\dist\\formly.js",
        "lib\\bootstrap-material-design-icons\\css\\material-icons.css",
        "lib\\ngToast\\dist\\ngToast.css",
    ]
}
```

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

| option        | defaut                            | description                                                  |
|:--------------|:----------------------------------|:-------------------------------------------------------------|
| `configFile`  | `modpack.json`                    | name of configuration file                                   |
| `min`         | `false`                           | if true then include '.min' to injected file                 |
| `dev`         | `true`                            | if true inject developping files instead of concatened files |
| `keepComment` | `true`                            | keep the placeholder comment wraping the injection           |
| `hash`        | `''`                              | added between filename and [.min].(js/css)                   |
| `jsStart`     | `'<script src="'`                 |                                                              |
| `jsEnd`       | `'"></script>'`                   |                                                              |
| `cssStart`    | `'<link rel="stylesheet" href="'` |                                                              |
| `cssEnd`      | `'">'`                            |                                                              |

Please note that this function does not handle files, all it does is to inject elements inside your HTML code. So, if you set `options.min` true for instance all it does it to inject `<script src="app.min.js"></script>` (including the min to its name). Is up to you to generate that minified file elsewhere.
