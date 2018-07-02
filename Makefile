VERSION = 0.4

bin: clean

clean:
	rm *~ *#

package:
	tar -cvzf SparenDNHAPM_$(VERSION).tar.gz README.md SparenDNHAPM.dnh

