#include "logger.h"

Logger* Logger::getInstance(){

    if(m_loggerInstance == nullptr) {
        m_loggerInstance = new Logger();
    }

    return m_loggerInstance;
}