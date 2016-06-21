=head1 LICENSE

Copyright [1999-2016] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

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

package EnsEMBL::Web::ViewConfig::Location::MultiTop;

use strict;

use base qw(EnsEMBL::Web::ViewConfig);

sub init {
  my $self = shift;

  $self->set_default_options({
    show_top_panel => 'yes'
  });

  $self->image_config_type('MultiTop');
  $self->title('Comparison Overview');

  $self->set_default_options({
    opt_join_genes_top => 'off',
  });
}

sub init_form {
  my $self = shift;

  $self->add_fieldset('Comparative features');

  $self->add_form_element({
    type  => 'CheckBox',
    label => 'Join genes',
    name  => 'opt_join_genes_top',
    value => 'on',
  });

  $self->add_fieldset('Display options');

  $self->add_form_element({ type => 'YesNo', name => 'show_top_panel', select => 'select', label => 'Show panel' });
}

1;
