
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME => 'Net-RabbitMQ-Simple',
    VERSION_FROM => "lib/Net/RabbitMQ/Simple.pm",
    ABSTRACT => 'Simple way for RabbitMQ lib',
    PREREQ_PM => {
        'Module::Build' => 0.36,
        'ExtUtils::MakeMaker' => 6.31,
        'ExtUtils::Install' => 1.46,
        'Test::More' => 0.90,
        'Moose' => 1.05,
        'MooseX::LazyRequire' => 0.06,
        'namespace::autoclean' => 0.11,
    },
    LICENSE => 'perl'
);

