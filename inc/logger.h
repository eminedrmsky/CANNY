#ifndef __LOGGER_H__
#define __LOGGER_H__

class Logger {

    //Naive singleton implementation
    
    protected:
        Logger() = default;

        static Logger* m_loggerInstance;

    public:

        Logger(Logger &t_otherLogger) = delete; //should not be cloneble

        void operator=(const Logger &) = delete; //should not be assignable

        static Logger* getInstance();
};

Logger* Logger::m_loggerInstance = nullptr;


#endif // __LOGGER_H__