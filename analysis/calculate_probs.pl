#!/usr/bin/perl -w

use Math::GMPz qw(:mpz);
use Math::GMPf qw(:mpf);

sub choose {
    my $x = shift;
    my $y = shift;
    
    if ($y < 0 || $y > $x) {
        return Math::GMPz->new(0);
    }
    if ($y == 0 || $y == $x) {
        return Math::GMPz->new(1);
    }
    my $answer = Math::GMPz->new(1);
    for (my $i = ($x - $y + 1); $i <= $x; $i++ ) {
        $answer = $answer * Math::GMPz->new($i);
    }
    for (my $j = 1; $j <= $y; $j++ ) {
        $answer = $answer / Math::GMPz->new($j);
    }
    return $answer;
}

sub calc {
    my $n = shift || 340;
    my $t = shift || 1700;
    my $x = shift || 0.00515359;
    
    my $result = Math::GMPf->new(0);
    for (my $i = 1; $i <= $n; $i++) {
        my $tempresult = Math::GMPf->new(1);
        my $choose = Math::GMPf->new();
        Rmpf_set_z($choose, choose($n,$i));
        $tempresult = $tempresult * $choose;

        my $temp = Math::GMPf->new();
        Rmpf_pow_ui( $temp, Math::GMPf->new( 1.0 - $x ) ,$i);

        my $temp2 = Math::GMPf->new();
        Rmpf_pow_ui( $temp2, $temp, $t);
        
        $tempresult = $tempresult * $temp2;
        $tempresult = $tempresult * Math::GMPf->new( (-1)**($i+1) );
        $result = $result + $tempresult;
    }
    return $result;
}

Rmpf_set_default_prec(1024);
for (my $trials = 100; $trials <= 3000; $trials += 25 ) {
    my $result = Math::GMPf->new(1.0) - calc(340,$trials,0.00515359);
    printf "$trials\t";
    Rmpf_printf("%32Ff\n", $result);
}
