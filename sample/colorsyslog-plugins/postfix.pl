# postfix.pl - postfix color plugin for colorsyslog script.
# xtetsuji 2016/05/22

sub {
    my ($message, %property) = @_;
    return if $property{process} !~ /^postfix/;

    # this "state", only low cost "my"
    my %postfix_status_color = (
        sent     => "green",
        deferred => "yellow",
        bounced  => "on_red white",
    );
    my $status_re = qr/\bstatus=(\S+)/;

    # queue coloring
    $message =~ s/^([A-Z0-9]{9,16})(?=:)/ colored($1, "on_green") /e;
    $message =~ s/^(NOQUEUE)(?=:)/ colored($1, "on_yellow") /e;
    $message =~ s/(reject:)/ colored($1, "red") /e;

    if ( my ($status) = $message =~ /$status_re/ ) {
        $message =~ s{$status_re}{
            my $color =  $postfix_status_color{$status} || "black";
            colored("status", "blue") . "=" . colored($status, $color);
        }e;
        my $msg_color = +{
            bounced  => "red",
            deferred => "yellow",
        }->{$status};
        $message =~ s{(\(.*?\))$}{ colored($1, $msg_color) }e if $msg_color;
    }
    return $message;
};
