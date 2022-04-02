package FoscamViewer::Camera;
use strict;
use warnings;
use Carp qw(croak);
use LWP::UserAgent;

sub new {
  my $class = shift;
  my %params = @_;
  my $self = {};
  bless $self, $class;

  foreach my $required_param (qw( base_url )) {
    croak "required parameter '$required_param' missing"
      unless defined $params{$required_param};
    $self->{$required_param} = $params{$required_param};
  }

  if (!defined $self->{motion_seconds}) {
    $self->{motion_seconds} = 0.5;
  }

  $self->{ua} = LWP::UserAgent->new();

  return $self;
}

sub base_url {
  my $self = shift;
  return $self->{base_url};
}

sub set_username {
  my ($self, $username) = @_;
  $self->{username} = $username;
}

sub set_password {
  my ($self, $password) = @_;
  $self->{password} = $password;
}

sub set_motion_seconds {
  my ($self, $seconds) = @_;
  $self->{motion_seconds} = $seconds;
}

sub camera_command {
  my $self = shift;
  my $command = shift;
  my %args = @_;
  my $ua = $self->{ua};
  my $url = $self->{base_url} . "/cgi-bin/CGIProxy.fcgi?cmd=$command";
  foreach my $arg (keys %args) {
    $url .= "&$arg=" . $args{$arg};
  }
  if (!defined $args{usr}) {
    $url .= "&usr=" . $self->{username} . "&pwd=" . $self->{password};
  }
  my $response = $ua->get($url);
  die $response->status_line unless $response->is_success;
  return $response->decoded_content;
}

sub snapshot_jpeg {
  my $self = shift;
  return $self->camera_command('snapPicture2');
}

sub move_up {
  my $self = shift;
  $self->camera_command('ptzMoveUp');
  select(undef, undef, undef, $self->{motion_seconds});
  $self->camera_command('ptzStopRun');
}

sub move_down {
  my $self = shift;
  $self->camera_command('ptzMoveDown');
  select(undef, undef, undef, $self->{motion_seconds});
  $self->camera_command('ptzStopRun');
}

sub move_left {
  my $self = shift;
  $self->camera_command('ptzMoveLeft');
  select(undef, undef, undef, $self->{motion_seconds});
  $self->camera_command('ptzStopRun');
}

sub move_right {
  my $self = shift;
  $self->camera_command('ptzMoveRight');
  select(undef, undef, undef, $self->{motion_seconds});
  $self->camera_command('ptzStopRun');
}

1;
