VERSION = 0.5

bin: clean

clean:
	rm *~ *#

package:
	tar -cvzf SparenDNHAPM_$(VERSION).tar.gz README.md SparenDNHAPM.dnh SparenDNHAPM_userdef.dnh

