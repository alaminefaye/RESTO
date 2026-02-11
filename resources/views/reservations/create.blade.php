@extends('layouts.app')
@section('title', 'Nouvelle Réservation')
@section('content')
<div class="row">
    <div class="col-md-8 mx-auto">
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">Nouvelle Réservation</h5>
                <small class="text-muted float-end">Création manuelle</small>
            </div>
            <div class="card-body">
                <form action="{{ route('reservations.store') }}" method="POST">
                    @csrf
                    
                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="nom_client">Client</label>
                        <div class="col-sm-9">
                            <div class="input-group input-group-merge">
                                <span class="input-group-text"><i class="bx bx-user"></i></span>
                                <input type="text" class="form-control @error('nom_client') is-invalid @enderror" id="nom_client" name="nom_client" value="{{ old('nom_client') }}" placeholder="Nom complet" required />
                                @error('nom_client')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                    </div>
                    
                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="telephone">Téléphone</label>
                        <div class="col-sm-9">
                            <div class="input-group input-group-merge">
                                <span class="input-group-text"><i class="bx bx-phone"></i></span>
                                <input type="text" class="form-control @error('telephone') is-invalid @enderror" id="telephone" name="telephone" value="{{ old('telephone') }}" placeholder="0123456789" required />
                                @error('telephone')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                    </div>

                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="email">Email (Optionnel)</label>
                        <div class="col-sm-9">
                            <div class="input-group input-group-merge">
                                <span class="input-group-text"><i class="bx bx-envelope"></i></span>
                                <input type="email" class="form-control @error('email') is-invalid @enderror" id="email" name="email" value="{{ old('email') }}" placeholder="client@exemple.com" />
                                @error('email')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                    </div>

                    <hr class="my-4">
                    
                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="table_id">Table</label>
                        <div class="col-sm-9">
                            <select class="form-select @error('table_id') is-invalid @enderror" id="table_id" name="table_id" required>
                                <option value="">Choisir une table...</option>
                                @foreach($tables as $table)
                                    <option value="{{ $table->id }}" {{ old('table_id') == $table->id ? 'selected' : '' }}>
                                        Table {{ $table->numero }} ({{ $table->type->displayName }} - {{ $table->capacite }} pers.) - 
                                        @if($table->prix_par_heure)
                                            {{ number_format($table->prix_par_heure, 0, ',', ' ') }} FCFA/h
                                        @else
                                            {{ number_format($table->prix, 0, ',', ' ') }} FCFA fixe
                                        @endif
                                    </option>
                                @endforeach
                            </select>
                            @error('table_id')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="date_reservation">Date</label>
                        <div class="col-sm-9">
                            <input type="date" class="form-control @error('date_reservation') is-invalid @enderror" id="date_reservation" name="date_reservation" value="{{ old('date_reservation', date('Y-m-d')) }}" min="{{ date('Y-m-d') }}" required />
                            @error('date_reservation')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="heure_debut">Heure de début</label>
                        <div class="col-sm-9">
                            <input type="time" class="form-control @error('heure_debut') is-invalid @enderror" id="heure_debut" name="heure_debut" value="{{ old('heure_debut') }}" required />
                            @error('heure_debut')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="duree">Durée (heures)</label>
                        <div class="col-sm-9">
                            <input type="number" class="form-control @error('duree') is-invalid @enderror" id="duree" name="duree" value="{{ old('duree', 1) }}" min="1" max="12" required />
                            @error('duree')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="nombre_personnes">Nombre de personnes</label>
                        <div class="col-sm-9">
                            <input type="number" class="form-control @error('nombre_personnes') is-invalid @enderror" id="nombre_personnes" name="nombre_personnes" value="{{ old('nombre_personnes', 2) }}" min="1" required />
                            @error('nombre_personnes')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="row mb-3">
                        <label class="col-sm-3 col-form-label" for="notes">Notes</label>
                        <div class="col-sm-9">
                            <textarea class="form-control @error('notes') is-invalid @enderror" id="notes" name="notes" rows="3" placeholder="Notes spéciales, préférences...">{{ old('notes') }}</textarea>
                            @error('notes')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="row justify-content-end">
                        <div class="col-sm-9">
                            <button type="submit" class="btn btn-primary">Enregistrer la réservation</button>
                            <a href="{{ route('reservations.index') }}" class="btn btn-outline-secondary">Annuler</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
