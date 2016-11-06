/*
Software to interface an FT232RL to a SGP18T display
(C) 2012 Jeroen Domburg (jeroen AT spritesmods.com)

This program is free software: you can redistribute it and/or modify
t under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <gd.h>

//Show the png-file called filename on the LCD
void lcdShowImage(char* filename) {
	FILE *f;
	int x, y, z, p, out[16][4];
	unsigned int col;
	gdImagePtr img;
	f=fopen(filename,"r");
	if (f==NULL) {
		perror(filename);
		return;
	}
	img=gdImageCreateFromPng(f);
	fclose(f);
	if (img==NULL) {
		printf("Couldn't load image: %s\n", filename);
		return;
	}
	for (y=0; y<16; y++) {
		for (x=0; x<8; x++) {
			p=gdImageGetPixel(img, x, y);
			col=gdImageRed(img, p)>>4;
			for (z=0; z<4; z++) {
				out[y][z]<<=1;
				if (col&(1<<z)) out[y][z]|=1;
			}
		}
	}

	for (z=0; z<4; z++) {
			printf("\tdb ");
		for (y=0; y<16; y++) {
			printf("%d%s", out[y][z]&0xff, y!=15?", ":"\n");
		}
	}
}

//Main function
int main(int argc, char **argv) {
	int x;
	for (x=1; x<argc; x++) {
		lcdShowImage(argv[x]);
	}
}
