rm *.png
mplayer  ../Rick\ Astley\ -\ Never\ Gonna\ Give\ You\ Up-dQw4w9WgXcQ.mp4 -noaspect -vf crop=920:700:180:10,scale=240:160 -vo png -ao null  -frames $((200*2))
rm *[13579].png
for x in *.png; do
	convert -resize 24x16 $x sc-$x
done
../convimg/imgconv 0 sc-*.png > ../mov1.inc
../convimg/imgconv 1 sc-*.png > ../mov2.inc
../convimg/imgconv 2 sc-*.png > ../mov3.inc



