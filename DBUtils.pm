package DBUtils;

sub ReceiveValueFromDatabase {
    my ($id, $dbh, $tableName, $idName, $valueName) = @_;
    my $SQL = "select $valueName from $tableName where $idName = ?";
    my $sth = $dbh->prepare($SQL);
    $sth->execute( $id );
    while ( my @row = $sth->fetchrow_array ) {
        return $row[0];
    }
}

sub ReceiveValuesFromDatabase {
    my ($dbh, $tableName, $valueName) = @_;
    my $SQL = "select $valueName from $tableName";
    my $sth = $dbh->prepare($SQL);
    $sth->execute();
    return $sth->fetchall_arrayref;
}

sub GetIdOrInsertToDatabase {
    my ($searchValue, $dbh, $tableName, $searchByColumn, $valueName) = @_;
    local *getValueId = sub {
        ReceiveValueFromDatabase($searchValue, $dbh, $tableName, $searchByColumn, $valueName);
    };
    my $InsertSQL = "insert into $tableName($searchByColumn) values (?)";
    my $receivedValue = getValueId();
    if($receivedValue) {
        return $receivedValue;
    }
    my $sth = $dbh->prepare($InsertSQL);
    $sth->execute( $searchValue );
    return getValueId();
}

1;