#!/bin/bash

function check
{
  du -h $nomgif.gif
  RESULTS_SIZE=`stat -c %s "$nomgif.gif"`

  if [ "$RESULTS_SIZE" -le 2087643 ]
    then
      echo "OK !"

      rm $nom*.$extension
      rm $nom.gif
      rm -r $nom
      exit
  fi

  (( i++ ))
  nomgif="${nom}_${i}"
  echo ""
}

nom=$1
i="1"
nomgif="${nom}_${i}"
fuzz="2%"

if [ -f "mask.png" ]
then
  echo "Utilisation du masque..."

  for fichierMasque in `ls ${nom}*.jpg`
  do
    echo "Application du masque à $fichierMasque..."
    composite -compose Dst_In mask.png $fichierMasque -alpha Set ${fichierMasque%.jpg}.png
  done

  mogrify -format png ${nom}0000.jpg 

  extension="png"
  rm ${nom}*.jpg
  rm mask.png

  echo ""
else
  extension="jpg"
fi

echo "Création du GIF $1"
rm $1
mkdir $1

echo ""
echo "Fuzz 0% - 1280x720"
convert -layers OptimizeTransparency -fuzz "0%" -delay 6 -loop 0 $1*.$extension $1.gif
gifsicle -w -O3 -d 4 $1.gif > $nomgif.gif
check

echo "Fuzz $fuzz - 1280x720"
convert -layers OptimizeTransparency -fuzz "$fuzz" -delay 6 -loop 0 $1*.$extension $1.gif
gifsicle -w -O3 -d 4 $1.gif > $nomgif.gif
check

echo "Fuzz 0% - 1280x720 - 256 couleurs"
gifsicle -w -O3 -d 4 --colors 256 $1.gif > $nomgif.gif
check

echo "Fuzz $fuzz - 1280x720 - 256 couleurs"
gifsicle -w -O3 -d 4 --colors 256 $1.gif > $nomgif.gif
check

echo "Redimensionnement..."
mogrify -resize 640x360 $1*.$extension
echo ""

echo "Fuzz 0% - 640x360"
convert -layers OptimizeTransparency -fuzz "0%" -delay 6 -loop 0 $1*.$extension $1.gif
gifsicle -w -O3 -d 4 $1.gif > $nomgif.gif
check

echo "Fuzz $fuzz - 640x360"
convert -layers OptimizeTransparency -fuzz "$fuzz" -delay 6 -loop 0 $1*.$extension $1.gif
gifsicle -w -O3 -d 4 $1.gif > $nomgif.gif
check

echo "Fuzz 0% - 640x360 - 256 couleurs"
gifsicle -w -O3 -d 4 --colors 256 $1.gif > $nomgif.gif
check

echo "Fuzz $fuzz - 640x360 - 256 couleurs"
gifsicle -w -O3 -d 4 --colors 256 $1.gif > $nomgif.gif
check

echo "Fuzz 0% - 640x360 - Division du nombre de frames par 2"  
mv $1???[13579].$extension $1  
convert -layers OptimizeTransparency -fuzz "0%" -delay 6 -loop 0 $1*.$extension $1.gif
gifsicle -w -O3 -d 8 $1.gif > $nomgif.gif
check

echo "Fuzz 0% - 640x360 - Division du nombre de frames par 2 - 256 couleurs"
gifsicle -w -O3 -d 8 --colors 256 $1.gif > $nomgif.gif
check

echo "Fuzz $fuzz - 640x360 - Division du nombre de frames par 2"  
convert -layers OptimizeTransparency -fuzz "$fuzz" -delay 6 -loop 0 $1*.$extension $1.gif
gifsicle -w -O3 -d 8 $1.gif > $nomgif.gif
check

echo "Fuzz $fuzz - 640x360 - Division du nombre de frames par 2 - 256 couleurs"
gifsicle -w -O3 -d 8 --colors 256 $1.gif > $nomgif.gif
check

echo "Fuzz 0% - 384x216"
mv $1/* .
echo "Redimensionnement..."
mogrify -resize 384x216 $1*.$extension
echo "Création du GIF..."
convert -layers OptimizeTransparency -fuzz "0%" -delay 6 -loop 0 $1*.$extension $1.gif
gifsicle -w -O3 -d 4 $1.gif > $nomgif.gif
check

echo "Fuzz 0% - 384x216 - 256 couleurs"
gifsicle -w -O3 -d 4 --colors 256 $1.gif > $nomgif.gif
check

echo "Fuzz $fuzz - 384x216"
convert -layers OptimizeTransparency -fuzz "$fuzz" -delay 6 -loop 0 $1*.$extension $1.gif
gifsicle -w -O3 -d 4 $1.gif > $nomgif.gif
check

echo "Fuzz $fuzz - 384x216 - 256 couleurs"
gifsicle -w -O3 -d 4 --colors 256 $1.gif > $nomgif.gif
check

echo "Fuzz 0% - 384x216 - Division du nombre de frames par 2"  
mv $1???[13579].$extension $1  
convert -layers OptimizeTransparency -fuzz "0%" -delay 6 -loop 0 $1*.$extension $1.gif
gifsicle -w -O3 -d 8 $1.gif > $nomgif.gif
check

echo "Fuzz 0% - 384x216 - Division du nombre de frames par 2 - 256 couleurs"
gifsicle -w -O3 -d 8 --colors 256 $1.gif > $nomgif.gif
check

echo "Fuzz $fuzz - 384x216 - Division du nombre de frames par 2"  
convert -layers OptimizeTransparency -fuzz "$fuzz" -delay 6 -loop 0 $1*.$extension $1.gif
gifsicle -w -O3 -d 8 $1.gif > $nomgif.gif
check

echo "Fuzz $fuzz - 384x216 - Division du nombre de frames par 2 - 256 couleurs"
gifsicle -w -O3 -d 8 --colors 256 $1.gif > $nomgif.gif
check

echo "Ficher trop grand - Abandon"
      
rm $1*.$extension
rm $1.gif
rm -r $1
