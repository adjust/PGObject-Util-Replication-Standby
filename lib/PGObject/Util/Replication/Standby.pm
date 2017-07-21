package PGObject::Util::Replication::Standby;

use 5.006;
use strict;
use warnings;
use Moo;
extends 'PGObject::Util::Replication::SMO';


=head1 NAME

PGObject::Util::Replication::Standby - Manage PG replication standbys

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS


    use PGObject::Util::Replication::Standby;

    my $replica = PGObject::Util::Replication::Standby->new();
    $replica->useslot('denver', 1);
    $replica->follow('pgmain.chicago.mydomain.foo');

    #however you may be better off setting cert auth instead.
    $replica->credentials('foo', 'superdupersecret');

    # finally get the recovery.conf contents
    $replica->recoveryconf->filecontents();

    ### manage replication slots
    # clearing all slots, for example failing over
    $replica->clearslots();

    # list all slots
    $replica->slots();

    # add new slot
    $replica->addslot('downstream1');

    # delete slot
    $replica->deleteslot('downstream2');
    

    #also ways to measure recovery lag
    $lsn = $standby->recovery_lsn(); # current recovery log location
    $standby->recovery_lag($lsn);

    $standby->promote();

    # we can also get the master from the connection string, for example to look up the 
    # wal segments

    my $wal_info = $standby->master->ping_wall();

=head1 DESCRIPTION AND USE

This module manages replication-related functions on standbys.

A I<standby> is a physical replica (i.e. data files are brought to the same
structure).  Logical replication in this case is not supported in terms of
failover and the like.

This module was written to make the task of managing replicated systems from
Rex much easier.  The module thus supports the three basic aspects of 
replication management:

=over

=item Configuration management of upstream and downstream links

=item WAL telemetry on the receiving end, and calculating lag

=item Promotion of a standby in a failover case.

=back

=head1 STANDBY PROPERTIES

All of those of an SMO plus

=head2 recoveryconf

The config manager for the PostgreSQL 

=cut 

has recoveryconf => (is => lazy);

sub _build_recoveryconf {
    my ($self) = @_;
    return PGObject::Util::PGConfig->new();
}

=head2 upstream_host

=head2 upstream_port

=head2 upstream_user

=head2 upstream_password

=head2 standby_name

=cut

has upstream_host;
has upstream_port;
has upstream_user;
has upstream_password;
has standby_name;

=head1 METHODS

=head2 Recovery Configuration

Recovery configuration here provides a basic interface for working with the parameters
in the recovery.conf file.  Note that this file cannot be managed via ALTER SYSTEM
so a physical file must be generated even once this is supported in PGObject::Util::PGConfig

=head3 set_recovery_param($name, $value)

Sets the parameter for the recovery.conf

=cut

sub set_recovery_param {
    my ($self, $name, $value) = @_;
    $self->recoveryconf->set_value($name, $value);
}

=head3 connection_string

Generates the connection string from the current attributes for the SMO.

=head3 from_recoveryconf($path)

Sets all appropriate parameters from a given recovery.conf at a valid path.

=head2 WAL telemetry

WAL telemetry works differently on standby than on a master.  The standby is not in charge
of writes and so there is no "current" wal location.  Instead we go by the latest received
location.

This has a number of important implications.  After STONITH, we can quickly poll a set of replicas to see who is most current and redirect traffic there.  This is most useful in a server down
situation so you can ensure that the most recent replica is failed over to.

This can also be used to check WAL telemetry against that on the master to see if there are 
slow links regarding non-synchronous standby servers and the like.

=head2 Upstream traversal

=head3 upstream()

Provides a generic SMO for the immediate upstream server.

=head3 master()

Traverses upstream until it finds a server which is not recovering and returns a Master SMO for
that server.

=head2 Promotion

Promotion can be done in this case if we can touch a trigger file specified in the recovery.conf
or if we can remove the recovery.conf and restart PostgreSQL.

=cut


=head1 AUTHOR

Chris Travers, C<< <chris.travers at adjust.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pgobject-util-replication-standby at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PGObject-Util-Replication-Standby>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PGObject::Util::Replication::Standby


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PGObject-Util-Replication-Standby>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PGObject-Util-Replication-Standby>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PGObject-Util-Replication-Standby>

=item * Search CPAN

L<http://search.cpan.org/dist/PGObject-Util-Replication-Standby/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2017 Adjust.com

This program is distributed under the (Revised) BSD License:
L<http://www.opensource.org/licenses/BSD-3-Clause>

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

* Neither the name of Adjust.com
nor the names of its contributors may be used to endorse or promote
products derived from this software without specific prior written
permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of PGObject::Util::Replication::Standby
