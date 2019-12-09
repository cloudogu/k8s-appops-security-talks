<div class="fragment"><a href='https://twitter.com/haveibeenpwned' class="social" target="_blank"><i class='fab fa-twitter'></i>@haveibeenpwned</a>
<br><a href="https://haveibeenpwned.com/PwnedWebsites">🌐  https://haveibeenpwned.com/PwnedWebsites</div> 

Notes:
* about 400 breaches

```bash
tmpFile=$(mktemp)
curl -sS https://haveibeenpwned.com/PwnedWebsites >  ${tmpFile} 

cat ${tmpFile} \
 | grep PwnedLogos \
 | sed 's/<img class="pwnLogo large" src="/https:\/\/haveibeenpwned.com/' \
 | sed 's/" alt=.*\/>//' \
 | xargs wget --no-clobber
# Yields duplicate Email.pngs
cat ${tmpFile} \
 | grep PwnedLogos \
 | grep -vE 'List.png|Email.png' \
 | sort \
 | sed -r 's/<img class="pwnLogo large" src="\/Content\/Images(.*)" alt="(.*)" \/>/<img data-src="images\1" width="16px" alt="\2" title="\2" \/>/' \
 > 01b-pawned-logos.md
``` 