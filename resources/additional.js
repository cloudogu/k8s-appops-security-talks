if (!window.location.search.match( /print-pdf/gi )) {
    const style = document.createElement('style');
    style.type = 'text/css';
    style.innerHTML = '.printOnly { display: none !important; };'
    document.getElementsByTagName('head')[0].appendChild(style);
}