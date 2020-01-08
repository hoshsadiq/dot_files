#[[ "$BROWSER"  ]] && alias -s {htm,html,de,org,net,com,at,cx,nl,se,dk}=$BROWSER
#[[ "${VISUAL:-$EDITOR}" ]] && alias -s {cpp,cxx,cc,c,hh,h,inl,asc,md,txt,TXT,tex}=${VISUAL:-$EDITOR}
#[[ "$XIVIEWER" ]] && alias -s {jpg,jpeg,png,gif,mng,tiff,tif,xpm}=$XIVIEWER
#
#(( ${+commands[vlc]} )) && alias -s {ape,avi,flv,m4a,mkv,mov,mp3,mp4,mpeg,mpg,ogg,ogm,rm,wav,webm}=vlc
#
##read documents
#alias -s pdf=zathura ps=gv dvi=xdvi chm=xchm djvu=djview
#
##list whats inside packed file
#alias -s zip="unzip -l" rar="unrar l" tar="tar tf" tar.gz="echo " ace="unace l"
