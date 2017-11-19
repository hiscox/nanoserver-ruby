# Temp Core Image
FROM microsoft/windowsservercore:latest AS core

ENV RUBY_VERSION 2.3.3
ENV DEVKIT_VERSION 4.7.2
ENV DEVKIT_BUILD 20130224-1432

RUN mkdir C:\\tmp
ADD https://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-${RUBY_VERSION}-x64.exe C:\\tmp
RUN C:\\tmp\\rubyinstaller-%RUBY_VERSION%-x64.exe /silent /dir="C:\Ruby_%RUBY_VERSION%_x64" /tasks="assocfiles,modpath"
ADD https://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-64-${DEVKIT_VERSION}-${DEVKIT_BUILD}-sfx.exe C:\\tmp
RUN C:\\tmp\\DevKit-mingw64-64-%DEVKIT_VERSION%-%DEVKIT_BUILD%-sfx.exe -o"C:\DevKit" -y

# Final Nano Image
FROM microsoft/nanoserver:latest AS nano

ENV RUBY_VERSION 2.3.3
ENV RUBYGEMS_VERSION 2.7.1
ENV BUNDLER_VERSION 1.16.0

COPY --from=core C:\\Ruby_${RUBY_VERSION}_x64 C:\\Ruby_${RUBY_VERSION}_x64
COPY --from=core C:\\DevKit C:\\DevKit

RUN setx PATH %PATH%;C:\DevKit\bin;C:\Ruby_%RUBY_VERSION%_x64\bin -m
RUN ruby C:\\DevKit\\dk.rb init
RUN echo - C:\\Ruby_%RUBY_VERSION%_x64 > C:\\config.yml
RUN ruby C:\\DevKit\\dk.rb install

RUN mkdir C:\\tmp
ADD https://rubygems.org/gems/rubygems-update-${RUBYGEMS_VERSION}.gem C:\\tmp
RUN gem install --local C:\tmp\rubygems-update-%RUBYGEMS_VERSION%.gem --no-ri --no-rdoc
RUN rmdir C:\\tmp /s /q

RUN gem install bundler --version %BUNDLER_VERSION% --no-ri --no-rdoc

ADD https://curl.haxx.se/ca/cacert.pem C:/ProgramData/cacert.pem
RUN setx SSL_CERT_FILE C:\ProgramData\cacert.pem -m

RUN echo gem: --no-ri --no-rdoc > C:\\ProgramData\\gemrc

CMD [ "cmd" ]