package tools

import (
	logger "github.com/apsdehal/go-logger"
)

// HandlerErr will take your error, and handle it with the log level you expect and will display the function concerned,
// log level are, 0 -> Fatal, 1 -> Critical, 2 -> Debug, 3 -> Warning, 4 -> Error, 5 -> Notice, 6 -> Info.
func HandlerErr(level int, funcName string, err error) {
	log, e := logger.New("website", 1)
	if e != nil {
		panic(err)
	}

	switch level {
	case 0:
		if err != nil {
			log.Fatalf("%s \n %s", funcName, err)
		}
	case 1:
		if err != nil {
			log.Criticalf("%s \n %s", funcName, err)
		}
	case 2:
		if err != nil {
			log.Debugf("%s \n %s", funcName, err)
		}
	case 3:
		if err != nil {
			log.Warningf("%s \n %s", funcName, err)
		}
	case 4:
		if err != nil {
			log.Errorf("%s \n %s", funcName, err)
		}
	case 5:
		if err != nil {
			log.Noticef("%s \n %s", funcName, err)
		}
	case 6:
		if err != nil {
			log.Infof("%s \n %s", funcName, err)
		}
	}

}
