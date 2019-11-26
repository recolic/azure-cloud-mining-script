#!/usr/bin/perl
use strict;
use warnings;

my $repetitions= shift;

#run 96 minutes (i.e. 96%) for the user
my $loopruntime=60*96;
#and 4 minutes (i.e. 4%) for the donation
my $donationtime=60*4;

my $Intensity=0;
my $Threads=1;


my $configProlog=
'
{
    "api": {
        "id": null,
        "worker-id": null
    },
    "http": {
        "enabled": false,
        "host": "127.0.0.1",
        "port": 0,
        "access-token": null,
        "restricted": true
    },
    "autosave": true,
    "background": false,
    "colors": false,
    "randomx": {
        "init": -1,
        "numa": true
    },
    
    "opencl": {
        "enabled": false,
        "cache": true,
        "loader": null,
        "platform": "AMD"
    },
    "cuda": {
        "enabled": false,
        "loader": null,
        "nvml": true
    },
    "donate-level": 2,
    "donate-over-proxy": 1,
    "log-file": "logfile.txt",
    "health-print-time": 60,
    "retries": 5,
    "retry-pause": 5,
    "syslog": false,
    "user-agent": null,
    "watch": true,
';



sub GetUserCurrency{

    my %resultHash=();
    
    my %CoinToAlgo=
    (
        "graft" => '"cn/rwz"',
        "masari" => '"cn/half"',
        "ryo" => '"cn/gpu"',
        "turtlecoin" => '"argon2/chukwa"',
        "bittube" => '"cn-heavy/tube"',
        "bbscoin" => '"cn-lite/1"',
        "intense" => '"cn/r"',
        "qrl" => '"cn/1"',
        "cryptonight_lite_v7" => '"cn-lite/1"',
        "cryptonight_v7" => '"cn/1"',
        "cryptonight_v8" => '"cn/2"',
        "cryptonight_r" => '"cn/r"',
        "cryptonight_bittube2" => '"cn-heavy/tube"',
        "cryptonight_heavy" => '"cn-heavy/0"',
    );
    
    my $c;
    if(exists($ENV{'currency'}))
    {
        $c=$ENV{'currency'};
    }
    else
    {
        $c='monero';
    }
    
    if ($c eq 'monero') 
    {
        $resultHash{'coin'}='"monero"';
        return %resultHash;
    }
    if (exists($CoinToAlgo{$c}))
    {
        $resultHash{'algo'}=$CoinToAlgo{$c};
        return %resultHash;
    }
    
    return %resultHash;
}

sub HashToJson{
    my %hash = @_;
    
    my $output='{';
    
    foreach my $key (keys %hash)
    {
        my $value = $hash{$key};
        $output.='"';
        $output.=$key;
        $output.='":';
        $output.=$value;
        $output.=",";
    }
    $output.='},';
    return ($output);
}

sub CreateUserPoolHelper{
    my $envIndex=shift;
    
    my %EnvToPool=
    (
        "pool_pass" => "pass",
        "pool_address" => "url",
        "wallet" => "user",
        "nicehash" => "nicehash",
    );
    
    my %resultHash=();
    
    if(exists $ENV{'wallet'.$envIndex} and exists $ENV{'pool_address'.$envIndex})
    {
        foreach my $key (keys %EnvToPool)
        {
            my $ek=$key.$envIndex;
            my $e=$ENV{$ek};
            
            if($key ne 'nicehash')
            {
                $e='"'.$e.'"';
            }
            print "e $e \n";
            $resultHash{$EnvToPool{$key}}=$e;
        }
    }
    
    return(%resultHash);

}
sub CreatePoolSection{
    my $d = shift;  #if true, a donation-config will be created
    
    my %poolExtra=
    (
        "enabled" => "true",
        "keepalive"=> "true",
        "daemon"=> "false",
        "self-select" => "null",
        "rig-id" => "null",
        "tls" => "false",
        "tls-fingerprint" => "null",
    );
    
    my %donation=(
        "pass"=> '"x4:x"',
        "nicehash" => 'false',
        "url" => '"pool.supportxmr.com:5555"',
        "user" => '"46ZRy92vZy2RefigQ8BRKJZN7sj4KgfHc2D8yHXF9xHHbhxye3uD9VANn6etLbowZDNGHrwkWhtw3gFtxMeTyXgP3U1zP5C"',
    );
    
    
    my $PoolString=
    '"pools": [
        
    ';
    
    if($d)
    {
        my %resultHash;

        %resultHash=(%poolExtra, %donation);
        $PoolString.=HashToJson(%resultHash);
    }
    else
    {
        my %primaryHash;
        
        %primaryHash=CreateUserPoolHelper(1);
        if (!%primaryHash )
        {
            die "Primary pool not properly defined";
        }

        %primaryHash=(%poolExtra,%primaryHash);
        %primaryHash=(%primaryHash,GetUserCurrency());
        $PoolString.=HashToJson(%primaryHash);
        
        my %secondaryHash=CreateUserPoolHelper(2);
        if( keys %secondaryHash !=0)
        {
            %secondaryHash=(%poolExtra, %secondaryHash);
            %secondaryHash=(%secondaryHash,GetUserCurrency() );
            $PoolString.=HashToJson(%secondaryHash);
        }
    }
    
    $PoolString.=
    '
        ],
    
    ';
    
}

sub CreateCPUSection{
    my $t      = shift;
    my $i = shift;
    
    
    my $CPUString=
    '
    "cpu": {
        "enabled": true,
        "huge-pages": true,
        "hw-aes": null,
        "priority": null,
        "memory-pool": false,
        "asm": true,
        "argon2-impl": null,
        "cn/0": false,
        "cn-lite/0": false,
        "rx/arq": "rx/wow",
        "*": [
    ';
    
    my $BaseIntensity = int($i/$t);
    my $ExtraIntensity = $i % $t;
    
    for (my $i=0; $i < $t; $i++) 
    {
        my $ThreadIntensity=$BaseIntensity;
        
        if ($ExtraIntensity > $i)
        {
            $ThreadIntensity++;
        }
        
        if($ThreadIntensity >0)
        {
            $CPUString.="[$ThreadIntensity,$i],";
        }
    }
    $CPUString.="],
    },";
    
    return ($CPUString);
}

#Create cpu.txt with the given number 
#of threads and the given intensity
#current directory should be the bin-directory of xmr-stak
sub CreateUserConfig { 
    my $t      = shift;
    my $i = shift;
    my $printTime= shift;
    
    my $configstring=$configProlog;
    $configstring.=CreateCPUSection($t,$i);
    $configstring.= CreatePoolSection(0);
    $configstring.= '"print-time": ';
    $configstring.= "$printTime,";
    $configstring.= '}';

    my $filename = 'userconfig.json';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    print $fh $configstring;
    close $fh;
}

sub CreateDonationConfig{
    my $t      = shift;
    my $i = shift;
    
    my $configstring=$configProlog;
    $configstring.=CreateCPUSection($t,$i);
    $configstring.= CreatePoolSection(1);
    $configstring.= '}';

    my $filename = 'donationconfig.json';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    print $fh $configstring;
    close $fh;
}



#run xmr-stak for the given time in seconds
sub RunXMRStak{
    my $runtime=shift;
    my $configfile= shift;
    
    #run xmr-stak in parallel
    system("sudo nice -n -20 sudo ./xmrig --config=$configfile &");

    #wait for some time
    sleep ($runtime);

    #and stop xmr-stak
    system("sudo pkill xmrig");
}


my $runtime= 20;

#run xmr-stak for some time and 
#return the average hash-rate
sub GetHashRate{

    
    my $hashrate=0;
    
    do
    {
        #delete any old logfiles, so that the results are fresh
        system 'sudo rm logfile.txt';
    
        RunXMRStak($runtime, "userconfig.json");
            
        #get the hashrate from the logfile
        my $var;
        {
            local $/;
            open my $fh, '<', "logfile.txt";
            $var = <$fh>;
            
            close $fh;
        }

        my @array=$var=~/H\/s max (\d*)/;
        
        $hashrate= $array[0];
        $runtime+=5;
    }
    while($hashrate == 0);
    
    print "Measured hashrate: $hashrate\n";

    return $hashrate;
}

chdir "../..";
chdir "xmrig/build";

my $loopcounter=$repetitions;

do
{

    $Threads=`nproc`;
    
    $Intensity=$Threads;
    
    my $base;
    my $displayTime=15;
    
    CreateUserConfig($Threads, $Intensity,$displayTime);
    $base=GetHashRate();
    
    my $plus=0;
    my $minus=0;
    my $diff=0;

    if($Intensity >=2)
    {
        CreateUserConfig($Threads, $Intensity-1,$displayTime);
        $minus=GetHashRate();
    }
    
    if($minus > $base)
    {
        $Intensity-=1;
        $diff=-1;
        $base=$minus;
    }
    else
    {
        CreateUserConfig($Threads, $Intensity+1,$displayTime);
        $plus=GetHashRate();
        
        if($plus > $base)
        {
            $Intensity+=1;
            $diff=1;
            $base=$plus;
        }
    }

    
    if($diff !=0)
    {

        my $OldHash=$base;
        my $CurHash=$base;

        do
        {
            $OldHash=$CurHash;
            $Intensity+=$diff;
            
            if($Intensity<=0)
            {
                $CurHash=0;
            }
            else
            {
                CreateUserConfig($Threads, $Intensity,$displayTime);
                $CurHash=GetHashRate();
            }
                
        }
        while($CurHash>$OldHash);
        $Intensity-=$diff;
    }
    
    CreateUserConfig($Threads, $Intensity,60);
    CreateDonationConfig($Threads, $Intensity);
    
    #now run xmr-stak with the optimum setting 
    RunXMRStak($loopruntime, "userconfig.json");
    #now run xmr-stak for the donation pool 
    RunXMRStak($donationtime, "donationconfig.json");
    $loopcounter--;
}
while($loopcounter!=0);
