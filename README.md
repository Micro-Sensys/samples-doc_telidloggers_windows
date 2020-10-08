# samples-doc_telidloggers_windows / Windows DOC sample code for TELID®311 datalogger
This sample code is for handling **TELID®311** dataloggers on Windows devices using a Micro-Sensys USB RFID reader.

> For details on DOC communication check [Useful Links](#Useful-Links) 

## Requirements
* Delphi IDE
* Micro-Sensys RFID reader
* TELID®311 datalogger

## Implementation
This code shows how to use **TELID3xx_Native.dll** to communicate with a TELID®311 datalogger. 
There are functions available to find, read log and program new logging process.

> Class information is available under API documentation. See [Useful Links](#Useful-Links)

## Steps
Just import this project into Delphi IDE, make sure the Micro-Sensys USB RFID reader is connected to the computer and start the debug session.
There are buttons available for each provided function, and a *Memo* to show the result of the function

>> **TODO screenshot!!**
<!--- ![Screenshot](screenshot/SampleApp_SpcControl_AndroidJava.png) --->

 1. Check RFID reader is detected and Reader ID is shown in bottom part of the window
 2. Press *Scan for TELID datalogger* and check a TELID® dataloger is found
 3. Press *Read PARAMETERS from TELID* and check the function returns successfully
 4. Read Protocol using *Read Measurement PROTOCOL from TELID* or program new logging process using *Program PARAMETERS to TELID*

## Useful Links

* [Native Library and API documentation](https://www.microsensys.de/downloads/DevSamples/Libraries/Windows/TELID300%20-%20native%20library/)
* Check what offers our TELID®soft for PC! Download using [this link](https://www.microsensys.de/downloads/CDContent%20TELIDsoft.zip)
* GitHub *documentation* repository: [Micro-Sensys/documentation](https://github.com/Micro-Sensys/documentation)
	* [communication-modes/documentation](https://github.com/Micro-Sensys/documentation/tree/master/communication-modes/doc)

## Contact

* For coding questions or questions about this sample code, you can use [support@microsensys.de](mailto:support@microsensys.de)
* For general questions about the company or our devices, you can contact us using [info@microsensys.de](mailto:info@microsensys.de)

## Authors

* **Victor Garcia** - *Initial work* - [MICS-VGarcia](https://github.com/MICS-VGarcia/)
