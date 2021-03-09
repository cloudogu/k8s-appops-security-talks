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

# Update reveal.js version

Update tag of cloudogu/reveal.js in `Dockerfile`.

# Print slides / create PDF 

## Official / manual

* In Chrome: http://localhost:8000/?print-pdf
* Ctrl + P
* Save As PDF

See [reveal.js README](https://github.com/hakimel/reveal.js/#pdf-export)

Note that [internal links](https://github.com/hakimel/reveal.js/#internal-links) only work in the PDF using the following:

```html
<!-- works -->
<a href="#some-slide">Link</a> 
<!-- doesn't -->
<a href="#/some-slide">Link</a> 
```
## Continuous delivery

* The `Jenkinsfile` automatically creates a PDF on git push.
* The `<title>` of `index.html` is used as file name
* The PDF is attached to the Jenkins job. See `https://<jenkins-url>/job/<job-url>/lastSuccessfulBuild/artifact/`
* It's also deployed with the web-based application. See `https://<your-url>/<title of index.html>.pdf`

Compared to the one manually created there are at least the following differences:

* Video thumbnail not displayed
* Header and footer show "invisible" texts, that can be seen when marking the text
* Backgrounds are also exported (e.g. when using the `cloudogu-black` theme)