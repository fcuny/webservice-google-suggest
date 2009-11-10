use inc::Module::Install;
name 'Webservice-Google-Suggest';
all_from 'lib/WebService/Google/Suggest.pm';
requires 'LWP::UserAgent';
build_requires 'Test::More';
auto_set_repository;
WriteAll;
