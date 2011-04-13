package Pickles::Plugin::AntiCSRF;
use strict;
use String::Random qw(random_regex);
use Carp ();

sub install {
    my( $class, $pkg ) = @_;
    $pkg->add_trigger( post_render => sub {
        my $c = shift;
        unless ( $c->has_plugin('Session') ) {
            Carp::croak('You MUST load Pickles::Plugin::Session!');
        }

        if ($c->res->content_type !~ /html$/i) {
            # no need to waste time parsing the body if this is not
            # an HTML document
            return;
        }
        my $config = $c->config->{'Plugin::AntiCSRF'};
        my $token_name = $config->{token_name} || '_token';
        my $length = $config->{token_length} || 8;

        my $body = $c->res->body;
        my $token = 
            $c->session->get( $token_name ) || random_regex("[a-zA-Z0-9_]{$length}");
        $body =~ s{(<form\s.*method="?post"?.*?>)}{$1<input type="hidden" name="$token_name" value="$token" />}ig;
        $c->res->body( $body );
        $c->session->set( $token_name => $token );
    } );
    $pkg->add_trigger( pre_dispatch => sub {
        my $c = shift;
        my $token_name = 
            $c->config->{'Plugin::AntiCSRF'}->{token_name} || '_token';
        if ( $c->req->method eq 'POST' && !$c->stash->{skip_csrf_check} && !$c->args->{skip_csrf_check} ) {
            my $req_val = $c->req->param( $token_name );
            my $session_val = $c->session->get( $token_name );
            unless ( $req_val && $session_val && ($req_val eq $session_val) ) {
                $c->detect_csrf;
            }
        }
    } );
    unless ( $pkg->can('detect_csrf') ) {
        $pkg->add_method('detect_csrf' => sub {
            my $c = shift;
            $c->res->status( 403 );
            $c->res->body( 'Forbidden' );
            $c->finished( 1 );
            $c->abort;
        });
    }
}

1;

__END__

=head1 NAME

Pickles::Plugin::AntiCSRF - csrf block plugin

=head1 SYNOPSIS

  ## etc/routes.pl
  router {
      connect '/' => { controller => 'Root', action => 'index' };
      
      # protected!
      connect '/commit' => { controller => 'Root', action => 'commit' }, { method => 'POST' };
      # !! WARNING !!
      # get method is not protected!
      # So must be specified "method"
  };

  ## lib/MyApp/Context.pm
  
  __PACKAGE__->load_plugins(qw(Encode AntiCSRF));

=head1 config

  ## etc/config.pl

  return +{
      'Plugin::AntiCSRF' => {
          token_name => '_token',
          token_length => 8
      }
  };

=head1 how to skip

=head2 by trigger

  ## lib/MyApp/Context.pm

  __PACKAGE__->load_plugins(qw(Encode AntiCSRF));

  __PACKAGE__->add_trigger( init => sub {
      my( $c ) = @_;
      
      if ($c->req->path=~m|^/api|) {
          $c->stash->{skip_csrf_check}++;
      }
  } );

=head2 by routes.pl

  ## etc/routes.pl
  router {
      connect '/' => { controller => 'Root', action => 'index' };
    
      # no protected!
      connect '/api' => { controller => 'Root', action => 'api', skip_csrf_check => 1 }, { method => 'POST' };
  };

=cut
