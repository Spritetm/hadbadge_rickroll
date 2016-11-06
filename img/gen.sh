rm *.png
mplayer  ../Rick\ Astley\ -\ Never\ Gonna\ Give\ You\ Up-dQw4w9WgXcQ.mp4 -noaspect -vf crop=920:700:180:10,rotate=0,scale=160:320 -vo png -ao null  -frames $((170*2))
rm *[13579].png
for x in *.png; do
	convert -resize 8x16 $x sc-$x
done
../convimg/imgconv sc-*.png > ../mov.inc


