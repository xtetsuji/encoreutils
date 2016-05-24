# postfix.pl - postfix color plugin for colorsyslog script.
# xtetsuji 2016/05/22

sub {
    my ($message, %property) = @_;
    return if $property{process} !~ /^postfix/;

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

=pod

=head1 NAME

postfix.pl - colorsyslog plugin of postfix maillog

=head1 SYNOPSIS

  mkdir -p ~/.config/colorsyslog/plugins/
  cp postfix.log ~/.config/colorsyslog/plugins/
  colorsyslog /var/log/maillog

=head1 DESCRIPTIONS

Because postfix maillog format is syslog, you can use colorsyslog
to coloring postfix mail.log.

This plugin is coloring message part as postfix semantics.

=head1 COPYRIGHT AND LICENSE

OGATA Tetsuji E<lt>tetsuji.ogata@gmail.comE<lt>

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
