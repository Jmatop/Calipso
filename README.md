<p align="center">
  <img width="50%" height="50%" src="https://user-images.githubusercontent.com/91370388/159025827-bb050ff3-db9c-44e8-bc69-0e750156fb05.png">
</p>



**Calipso is a final project for 2n from ASIX at the Puig Castellar institute whose main function is to scan all the network traffic and show it in a graph and also tells you if you are being attacked and with what protocol you are being attacked.**


**For the moment Calipso only run on Fedora 34-36 Server.**


For install Calipso you need first to clone the repository:

If you dont have ```git``` installed run on terminal:

Fedora: ``` sudo dnf install git```

Then you can run:
```
git clone https://github.com/Jmatop/Calipso.git
```
For install Calipso only run ``` cd Calipso``` ```sudo chmod +x InstallFedora.sh``` ``` sudo bash install.sh```

Once everything is downloaded, inside the Calypso folder we find a file with the name *config-elastic* which within said file will be registered the password of kibana itself, once we have it copied we open the browser and go to the address *http://ip:5601*
