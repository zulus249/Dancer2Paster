package Dancer2Paster;
use Dancer2;
use MyDb;

our $VERSION = '0.1';

get '/' => sub {
    
    redirect uri_for('item', {'id' => params->{id}}) if defined params->{id};
    
    template 'index' => { 'title' => 'Dancer2Paster' };
};

get '/item' => sub {
    my $db = new MyDb;
    my $entry = $db->getEntry(params->{id});
    template 'id' => { 'entry' => $entry, 'success' => params->{success} };
};


post 'add' => sub {
    
    my $db = new MyDb;
    my $id = $db->add(request->remote_address,params->{text});
    
    redirect uri_for('crash') unless defined $id;
    
    redirect uri_for('item', {'id' => $id, 'success'=> '1' });
};

get '/crash' => sub {

    template 'crash' => {  };
};

get '/list' => sub {
   my $db = new MyDb;
   my $entries = $db->getLastEntries;
     template 'list' => {'id' => params->{id}, 'entries' => $entries};
};

true;
