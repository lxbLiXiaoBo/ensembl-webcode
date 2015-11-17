=head1 LICENSE

Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut

package EnsEMBL::Web::ImageConfig::ldmanplot;

use strict;

use base qw(EnsEMBL::Web::ImageConfig);

sub _menus {
  return (qw(
    transcript
    simple
    misc_feature
    prediction
    variation
    ld_population
    somatic
    other
    information
  ));
}

sub init {
  my $self    = shift;
  my $colours = $self->species_defs->colour('variation');
    
  $self->set_parameters({
    label_width => 100,
    colours     => $colours,  # colour maps
  });
  
  $self->create_menus($self->_menus);
  
  $self->load_tracks;
 
 
  $self->add_tracks('other',
    [ 'scalebar', '', 'scalebar', { display => 'normal', strand => 'r', name => 'Scale bar', description => 'Shows the scalebar'                             }],
    [ 'ruler',    '', 'ruler',    { display => 'normal', strand => 'f', name => 'Ruler',     description => 'Shows the length of the region being displayed' }],
  );
  
  $self->modify_configs(
    [ 'transcript_core_ensembl' ],
    { display => 'transcript_label' }
  );
 
  $self->modify_configs(
    ['simple', 'misc_feature'],
    { display => 'off', menu => 'no'}
  );

  $self->modify_configs(
    ['simple_otherfeatures_human_1kg_hapmap_phase_2'],
    {'display' => 'tiling', menu => 'yes'}
  );
 
  $self->modify_configs(
    [ 'variation_feature_variation' ],
    { display => 'normal', caption => 'Variations', strand => 'r' }
  );
}

sub init_slice {
  my ($self, $parameters) = @_;
  
  $self->set_parameters({
    %$parameters,
    _userdatatype_ID   => 30,
    _transcript_names_ => 'yes'
  });

  
 
#  $self->{'_ld_population'} = [];
 
  #$self->get_node('ld_population')->remove;
  #$self->get_node('ld_r2')->remove if ($self->get_node('ld_r2'));
  #$self->get_node('ld_d_prime')->remove if ($self->get_node('ld_d_prime'));
  #$self->get_node('variation')->remove;
}


sub add_populations {
  my ($self, $pops) = @_;

  my @pop_tracks = ();

  my $colours = $self->get_parameter('colours');
  my $var_name = ($self->hub->param('v')) ? 'variant '.$self->hub->param('v') : 'focus variant';


  my $display_options = qq{You can change the region size by clicking on the link "Display options" in the "Configure this page/image" popup.};
  my $desc = 'Linkage disequilibrium data (%s score) for the %s in the %s population. %s';

  foreach my $pop_name (sort { $a cmp $b } @$pops) {
    my $pop = $pop_name;
       $pop =~ s/ /_/g;

    my $r2_desc = sprintf($desc, 'r2', $var_name, $pop_name, $display_options); 
    my $d_prime_desc = sprintf($desc, 'D prime', $var_name, $pop_name, $display_options);

    push @pop_tracks, [ "ld_r2_$pop", '', 'ld_manplot', { display => 'compact', strand => 'r', caption => "LD (r2) - $pop_name", name => "LD (r2) - $pop_name", key => 'r2', description => $r2_desc, pop_name => $pop_name, colours => $colours, height => 100 } ];
    push @pop_tracks, [ "ld_d_prime_$pop", '', 'ld_manplot', { display => 'compact', strand => 'r', caption => "LD (D') - $pop_name", name => "LD (D') - $pop_name", key => 'd_prime', description => $d_prime_desc, pop_name => $pop_name, colours => $colours, height => 100 } ];
  
  }

  $self->add_tracks('ld_population', @pop_tracks);
}

1;
