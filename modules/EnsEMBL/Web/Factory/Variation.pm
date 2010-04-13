package EnsEMBL::Web::Factory::Variation;

use strict;
use warnings;
no warnings "uninitialized";

use HTML::Entities qw(encode_entities);

use base qw(EnsEMBL::Web::Factory);

sub _help {
  my( $self, $string ) = @_;

  my %sample = %{$self->species_defs->SAMPLE_DATA ||{}};

  my $help_text = $string ? sprintf( '
  <p>
    %s
  </p>', encode_entities( $string ) ) : '';
  my $url = $self->_url({ '__clear' => 1, 'action' => 'Summary', 'v' => $sample{'VARIATION_PARAM'} });


  $help_text .= sprintf( '
  <p>
    This view requires a variation identifier in the URL. For example:
  </p>
  <blockquote class="space-below"><a href="%s">%s</a></blockquote>',
    encode_entities( $url ),
    encode_entities( $self->species_defs->ENSEMBL_BASE_URL. $url )
  );

  return $help_text;
}


sub createObjects {
  my $self      = shift;
  my $dbh     = $self->species_defs->databases->{'DATABASE_VARIATION'};
  return $self->problem ('Fatal', 'Database Error', "There is no variation database for this species.") unless $dbh;
   
  my $dbs= $self->get_databases(qw(core variation));
  return $self->problem( 'Fatal', 'Database Error', "Could not connect to the core database." ) unless $dbs;
  my $variation_db = $dbs->{'variation'};
  return $self->problem( 'Fatal', 'Database Error', "Could not connect to the variation database." ) unless $variation_db;
  $variation_db->dnadb($dbs->{'core'});

  my $snp    = $self->param('snp') || $self->param('v');
  my $source = $self->param('source');
  return $self->problem( 'Fatal', 'Variation ID required',$self->_help( "A variation ID is required to build this page.") ) unless $snp;

  my $vari_adaptor = $variation_db->get_VariationAdaptor;
  my $snp_obj     = $vari_adaptor->fetch_by_name( $snp, $source);

  return $self->problem( 'Fatal', "Could not find variation $snp",
    $self->_help( "Either $snp does not exist in the current Ensembl database, or there was a problem retrieving it.")
  ) unless $snp_obj;

  $self->DataObjects( $self->new_object( 'Variation', $snp_obj, $self->__data ));
  #$self->problem( 'redirect', $self->_url({'vdb'=>'variation','v'=>$snp, 'pt' =>undef,'g'=>undef,'r'=>undef,'t'=>undef}));
}

1;
