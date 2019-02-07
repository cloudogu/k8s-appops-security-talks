# Wiki

You can find the presentation slides in the `slides` folder.

# Presentation

Realised using [reveal.js](https://github.com/hakimel/reveal.js/).

## Hotkeys

* `S` show Speaker Notes 
* `?` show all Hotkeys 
* `Esc` show slide overview ("grid")
* Cursors: Navigation (on slides "grid")
* `Space` next slide

See also [reveal.js wiki](https://github.com/hakimel/reveal.js/wiki/Keyboard-Shortcuts).

## Run locally

Either open `index.html` in a browser (no hot-reload) or use yarn/npm nutzen (see bellow).

### Install yarn and dependencies

Run only once

* Install `yarn` (also possible via npm, but deprecated)
* Run `yarn install`

### Start server for hot reload

`yarn start`  

* Starts web server with presentation on http://localhost:8000.
* The command does not return and watches the resources (slides, index, css, js) for changes. Seems not work on Windows.
* Reloads automatically on change (no refreshing necessary in the browser)

# Print slides / create PDF 

## Official

* In Chrome: http://localhost:8000/?print-pdf
* Ctrl + P
* Save As PDF
* Can be customized using a [separate Stylesheet](../css/print/pdf.css)

See [reveal.js README](https://github.com/hakimel/reveal.js/#pdf-export)

## An approach for automation

With headless Chrome (e.g. in Docker Container): 

`chromium-browser --headless --disable-gpu --virtual-time-budget=1000 --print-to-pdf=cd-slides-example.pdf "http://localhost:8000/?print-pdf"`  

(works with Chromium 63.0.3239.132)  
See also https://github.com/cognitom/paper-css/issues/13


## Demo content from slides for copy and pasting stuff

Realised using [reveal.js](https://github.com/hakimel/reveal.js/).

Write your slides in [GitHub-flavored markdown](https://guides.github.com/features/mastering-markdown/).

## Hotkeys

* `S` show Speaker Notes 
* `?` show all Hotkeys 
* `Esc` show slide overview ("grid")
* Cursors: Navigation (on slides "grid")
* `Space` next slide

Note:
* Speaker notes go here 



### Bellow (separated by three empty lines)

Emojis 👤 🛠️ 🚢 ❤ 👤 🌐 📋 🐋 📦 🐕 🐈 🇬🇧 🇩🇪 ⌨ ℹ️ 📕 ➡ 🥚 🏍 🕮 🌩️ <font color="red">⚠</font> 🚀 🔑 🔄 🗣 ️🎧 ⏪

<br/>

[Font Awesome](https://fontawesome.com/icons?d=gallery): 

<i class="fas fa-coffee"></i>
<i class='fas fa-thumbtack'></i>
<i class='fas fa-code-branch'></i>

<a href='https://twitter.com/cloudogu' class="social" target="_blank">
    <i class='fab fa-twitter'></i>
    twitter.com/cloudogu
</a>

<a href='https://github.com/cloudogu' class="social" target="_blank">
    <i class='fab fa-github'></i>
    github.com/cloudogu
</a>

---

## To the right (separeted by `---`)

Syntax highlighting 

```java
String hello = "world";
```
 
Quotes: 
> A container image is a lightweight, stand-alone, executable package of a piece of software that includes everything needed to run it: code, runtime, system tools, system libraries, settings.



## Separate files are placed to the right

Don't forget to add the markdown to `index.html`!

### Images

<!-- .slide: data-background-image="css/images/logo.png" data-background-size="50%" -->
<!-- .slide: style="text-align: left;" -->
 
Image via Markdown
![image](css/images/logo3.png)

<img src="css/images/logo3.png" class="floatLeft" width=20% />
<img src="css/images/logo1.png" class="floatRight" width=20% />
The images are floating right and left of this text via css






### Font
<!-- .slide: id="font" -->

* Normal
* <font color="red">red</font>  
  Line Break after two empty blanks
* <font size="1">Smaller text</font>



### Ordered List

1. Ordered
1. List


Link to [previous slide](#/font) (by id)

### Video

<iframe width="560" height="315" src="https://www.youtube.com/embed/4ht22ReBjno" allow="encrypted-media" allowfullscreen></iframe>