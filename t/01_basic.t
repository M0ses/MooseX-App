# -*- perl -*-

# t/01_basic.t - Basic tests

use Test::Most tests => 6+1;
use Test::NoWarnings;

use FindBin qw();
use lib 't/testlib';

use Test01;

subtest 'Excact command with option' => sub {
    explain();
    local @ARGV = qw(command_a --global 10);
    my $test01 = Test01->new_with_command;
    isa_ok($test01,'Test01::CommandA');
    is($test01->global,'10','Param is set');
};

subtest 'Fuzzy command with option' => sub {
    local @ARGV = qw(Command_A --global 10);
    my $test02 = Test01->new_with_command;
    isa_ok($test02,'Test01::CommandA');
    is($test02->global,'10','Param is set');
};

subtest 'Wrong command' => sub {
    local @ARGV = qw(xxxx --global 10);
    my $test03 = Test01->new_with_command;
    isa_ok($test03,'MooseX::App::Message::Envelope');
    is($test03->blocks->[0]->header,"Unknown command: xxxx",'Message is set');
    is($test03->blocks->[0]->type,"error",'Message is of type error');
    is($test03->blocks->[1]->header,"usage:",'Usage set');
    is($test03->blocks->[1]->body,"    01_basic.t command [long options...]
    01_basic.t help
    01_basic.t command --help",'Usage body set');
    is($test03->blocks->[2]->header,"global options:",'Global options set');
    is($test03->blocks->[2]->body,"    --config           Path to command config file
    --global           test [Required; Integer; Important!]
    --help --usage -?  Prints this usage information. [Flag]",'Global options body set');
    is($test03->blocks->[3]->header,"available commands:",'Available commands set');
    is($test03->blocks->[3]->body,"    command_a   Command A!
    command_b   Test class command B for test 01
    command_c1  Test C1
    help        Prints this usage information",'Available commands body set');
};

subtest 'Help for command' => sub {
    local @ARGV = qw(command_a --help);
    my $test04 = Test01->new_with_command;
    isa_ok($test04,'MooseX::App::Message::Envelope');
    is($test04->blocks->[0]->header,"usage:",'Usage is set');
    is($test04->blocks->[0]->body,"    01_basic.t command_a [long options...]
    01_basic.t help
    01_basic.t command_a --help",'Usage body set');
    is($test04->blocks->[1]->header,"description:",'Description is set');
    is($test04->blocks->[1]->body,"    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras dui velit,
    varius nec iaculis vitae, elementum eget mi.
    * bullet1
    * bullet2
    * bullet3
    Cras eget mi nisi. In hac habitasse platea dictumst.",'Description body set');
    is($test04->blocks->[2]->header,"options:",'Options header is set');
    is($test04->blocks->[2]->body,"    --command_local1   some docs about the long texts that seem to occur
                       randomly [Integer; Important; Env: LOCAL1]
    --command_local2   Verylongwordwithoutwhitespacestotestiftextformatingwor
                       ksproperly [Env: LOCAL2]
    --config           Path to command config file
    --global           test [Required; Integer; Important!]
    --help --usage -?  Prints this usage information. [Flag]",'Options body is set');
    #print $test04;
};

subtest 'With extra args' => sub {
    local @ARGV = qw(Command_b --global 10);
    my $test02 = Test01->new_with_command( 'param_b' => 'bbb', 'global' => 10  );
    isa_ok($test02,'Test01::CommandB');
    is($test02->global,'10','Param global is set');
    is($test02->param_b,'bbb','Param param_b is set');
};

subtest 'Wrapper script' => sub {
    my $output = `$^X $FindBin::Bin/example/test01.pl command_a --command_local2 test --global 10`;
    is($output,'RUN COMMAND-A:test','Output is ok');
};
