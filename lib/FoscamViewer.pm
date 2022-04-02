package FoscamViewer;
use Mojo::Base 'Mojolicious', -signatures;
use FoscamViewer::Camera;

sub validate_user {
  my ($app, $username, $password, $extradata) = @_;
  my $response = $app->camera->camera_command('getProductModel', usr => $username, pwd => $password);
  if ($response =~ m:<result>(\d+)</result>:s) {
    if ($1 eq '0') {
      return "$username:$password";
    } else {
      return undef;
    }
  }
  return undef;
}

sub load_user {
  my ($app, $uid) = @_;
  return undef if !defined $uid;
  my ($username, $password) = split /:/, $uid;
  my $user = {
    username => $username,
    password => $password,
  };
  return $user;
}

# This method will run once at server start
sub startup ($self) {

  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig');

  # Configure the application
  $self->secrets($config->{secrets});

  if (defined $config->{session_expiration_seconds}) {
    $self->sessions->default_expiration($config->{session_expiration_seconds});
  }

  $self->plugin('Authentication' => {
    load_user     => \&load_user,
    validate_user => \&validate_user,
  });

  # Change scheme if "X-Forwarded-HTTPS" header is set
  $self->hook(before_dispatch => sub ($c) {
    $c->req->url->base->scheme('https')
      if $c->req->headers->header('X-Forwarded-HTTPS');
  });

  # Move first part and slash from path to base path in production mode
  if (defined $config->{base_path}) {
    $self->hook(before_dispatch => sub ($c) {
      $c->req->url->base->path->parse($config->{base_path});
    });
  }

  $self->helper(camera => sub {
    my $this = shift;
    my $c = FoscamViewer::Camera->new(base_url => $config->{camera_baseurl});
    if (defined $config->{motion_seconds}) {
      $c->set_motion_seconds($config->{motion_seconds});
    }
    if ($this->is_user_authenticated) {
      $c->set_username($this->current_user->{username});
      $c->set_password($this->current_user->{password});
    }
    return $c;
  });

  $self->types->type(jpeg => 'image/jpeg');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to(cb => sub {
    my $self = shift;
    $self->redirect_to('camera');
  });

  my $camera = $r->under('/camera')->to('webapp#check_auth');

  $r->get('/login')->to('webapp#login_form');
  $r->post('/login')->to('webapp#login');

  $camera->get('/')->to('webapp#welcome');
  $camera->get('/snapshot')->to('webapp#snapshot');
  $camera->get('/stream')->to('webapp#stream');
  $camera->get('/move/up')->to('motion#up');
  $camera->get('/move/down')->to('motion#down');
  $camera->get('/move/left')->to('motion#left');
  $camera->get('/move/right')->to('motion#right');
}

1;
