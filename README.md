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

Once everything is downloaded, inside the Calypso folder we find a file with the name *config-elastic* which within said file will be registered the password of kibana itself, once we have it copied we open the browser and go to the address *http://ip-elastic:5601*

And we enter the requirements that it asks us, which are in the file mentioned above.

We return to the terminal and what we must do now is move the *test.rules* file to the necessary path.
To do this ``` mv test.rules /var/lib/suricata/rules/ ```

Now we have to edit the suricata file:
``` sudo nano /etc/suricata/suricata.yaml ```
Inside this file we need to find the *rule-files* and replace the line suricata.rules for:
``` test.rules ```

When we do that we need to download the GeoIP Database called *GeoLite2-Country.mmdb*, then we enter on the github and we download it:
*https://github.com/P3TERX/GeoLite.mmdb*

When we download it the file *GeoLite2-Country.mmdb* we move it to * /usr/share/GeoIP*

```sudo mv GeoLite2-Country.mmdb /usr/share/GeoIP/```

Finally we need to edit the fluent-bit file called */home/$USER/Calipso/pruebafinal.conf*
we need to edit this lines and put on *Host* the ip of elastic server and the HTTP_Passwd we put the password of elastic server 

![Screenshot_1](https://user-images.githubusercontent.com/91370388/171038528-5aac6e98-f076-4312-808e-da41ebcaacac.png)



Now we exec fluent-bit file:
``` sudo fluent-bit -c pruebafinal.conf ```
We go to Kibana and on Menu we select Stack Management and there we select saved objects and we export the file *export(1).ndjson*

![Screenshot_2](https://user-images.githubusercontent.com/91370388/171039233-e154696c-4f12-41dd-b551-e9162560b85e.png)

When we do that now we select the Dashboards and we have all there.

![Screenshot_1](https://user-images.githubusercontent.com/91370388/171039359-b0147b57-700d-48d7-bf4f-19afb10d0031.png)
![Screenshot_2](https://user-images.githubusercontent.com/91370388/171039391-498a6eb6-1923-46f5-bf7b-6b761bedce47.png)


